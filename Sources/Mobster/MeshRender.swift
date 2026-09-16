import Metal

/// The identity pass. A mesh is drawn opaque with depth into a single sampled target of whole identities, so occlusion follows from the depth test and no hidden line is removed by hand.
final class MeshRender: Sendable {
    private static let vertexName = "mobster_mesh_identity_vertex"
    private static let fragmentName = "mobster_mesh_identity_fragment"
    /// The identity is flat and integral through the whole pass, which is what holds it off being interpolated into a value that means nothing.
    static let source = """
    #include <metal_stdlib>
    using namespace metal;

    struct mobster_mesh_piece {
        float4 location [[position]];
        uint identity [[flat]];
    };

    vertex mobster_mesh_piece mobster_mesh_identity_vertex(const device float3 *locations [[buffer(0)]],
                                                           const device uint *identities [[buffer(1)]],
                                                           uint index [[vertex_id]]) {
        mobster_mesh_piece piece;
        piece.location = float4(locations[index], 1.0);
        piece.identity = identities[index / 3];
        return piece;
    }

    fragment uint mobster_mesh_identity_fragment(mobster_mesh_piece piece [[stage_in]]) {
        return piece.identity;
    }
    """
    /// The band of the clip volume the depth of a mesh is laid into. It stops short of either limit so the farthest fragment still draws rather than being cleared away by the test it ties with.
    private static let depthBand: Float = 0.5
    private static let depthOrigin: Float = 0.25

    private let queue: MTLCommandQueue
    private let pipeline: MTLRenderPipelineState
    private let depth: MTLDepthStencilState

    /// The pass is compiled from source: the package carries no resource bundle, and a twelve triangle draw does not earn a build plugin in front of every consumer's build. A device compiles it once, which MeshRenderCache is what holds.
    init(device: any MTLDevice, pass: String = MeshRender.source) throws(MeshRefusal) {
        guard let library = try? device.makeLibrary(source: pass, options: nil),
              let vertexFunction = library.makeFunction(name: Self.vertexName),
              let fragmentFunction = library.makeFunction(name: Self.fragmentName),
              let commands = device.makeCommandQueue() else { throw .pass }

        let description = MTLRenderPipelineDescriptor()
        description.vertexFunction = vertexFunction
        description.fragmentFunction = fragmentFunction
        description.colorAttachments[0].pixelFormat = .r32Uint
        description.depthAttachmentPixelFormat = .depth32Float

        let test = MTLDepthStencilDescriptor()
        test.depthCompareFunction = .less
        test.isDepthWriteEnabled = true

        guard let state = try? device.makeRenderPipelineState(descriptor: description),
              let comparison = device.makeDepthStencilState(descriptor: test) else { throw .pass }

        queue = commands
        pipeline = state
        depth = comparison
    }

    /// Nil where there is nothing to draw, which a Frame with no extent and a mesh of no triangles both are. A device that will not run the pass refuses instead, those two being different answers.
    func raster(of mesh: Mesh, in frame: Frame, resolution: MeshResolution) throws(MeshRefusal) -> MeshIdentityRaster? {
        guard resolution.columns > 0, resolution.rows > 0, mesh.triangles.isEmpty == false else { return nil }

        var locations = clipped(mesh, in: frame)
        var identities = mesh.triangles.map(\.identity.value)
        let device = queue.device
        let target = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Uint, width: resolution.columns, height: resolution.rows, mipmapped: false)
        target.usage = .renderTarget
        target.storageMode = .shared
        let test = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: resolution.columns, height: resolution.rows, mipmapped: false)
        test.usage = .renderTarget
        test.storageMode = .private

        guard let surface = device.makeTexture(descriptor: target),
              let depths = device.makeTexture(descriptor: test) else { throw .target(columns: resolution.columns, rows: resolution.rows) }
        guard let locationBuffer = device.makeBuffer(bytes: &locations, length: MemoryLayout<SIMD3<Float>>.stride * locations.count, options: .storageModeShared),
              let identityBuffer = device.makeBuffer(bytes: &identities, length: MemoryLayout<UInt32>.stride * identities.count, options: .storageModeShared) else { throw .buffers(triangles: mesh.triangles.count) }
        guard let commands = queue.makeCommandBuffer() else { throw .encoding }

        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = surface
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        pass.colorAttachments[0].clearColor = MTLClearColor(red: Double(MeshIdentityRaster.background), green: 0, blue: 0, alpha: 0)
        pass.depthAttachment.texture = depths
        pass.depthAttachment.loadAction = .clear
        pass.depthAttachment.clearDepth = 1
        pass.depthAttachment.storeAction = .dontCare

        guard let encoder = commands.makeRenderCommandEncoder(descriptor: pass) else { throw .encoding }
        encoder.setRenderPipelineState(pipeline)
        encoder.setDepthStencilState(depth)
        encoder.setVertexBuffer(locationBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(identityBuffer, offset: 0, index: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: locations.count)
        encoder.endEncoding()
        commands.commit()
        commands.waitUntilCompleted()

        var read = [UInt32](repeating: MeshIdentityRaster.background, count: resolution.fragments)
        read.withUnsafeMutableBytes { bytes in
            surface.getBytes(bytes.baseAddress!,
                             bytesPerRow: MemoryLayout<UInt32>.stride * resolution.columns,
                             from: MTLRegionMake2D(0, 0, resolution.columns, resolution.rows),
                             mipmapLevel: 0)
        }

        return MeshIdentityRaster(columns: resolution.columns, rows: resolution.rows, identities: read)
    }

    /// The Frame fills the clip volume across and down, and the depth of the mesh is normalized against its own extent, the nearest fragment taking the least depth so that it wins the test.
    private func clipped(_ mesh: Mesh, in frame: Frame) -> [SIMD3<Float>] {
        let depths = mesh.triangles.flatMap { [$0.first.z, $0.second.z, $0.third.z] }
        let near = depths.max() ?? 0
        let extent = near - (depths.min() ?? 0)

        return mesh.triangles.flatMap { triangle in
            [triangle.first, triangle.second, triangle.third].map { location in
                SIMD3<Float>((location.x - frame.origin.x) / frame.size.x * 2 - 1,
                             1 - (location.y - frame.origin.y) / frame.size.y * 2,
                             extent > 0 ? Self.depthOrigin + (near - location.z) / extent * Self.depthBand : Self.depthOrigin + Self.depthBand / 2)
            }
        }
    }
}
