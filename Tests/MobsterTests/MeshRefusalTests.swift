import Metal
import Testing
@testable import Mobster

struct MeshRefusalTests {
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))

    /// A pass that will not compile is the refusal the consumer is most likely to meet, the source being compiled on the device it runs on.
    @Test func aPassThatWillNotCompileRefuses() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())

        #expect(throws: MeshRefusal.pass) { try MeshRender(device: device, pass: "this is not a shading language") }
    }

    /// A pass that compiles and carries neither of the functions the render names refuses the same way, nothing having been found to draw with.
    @Test func aPassMissingItsFunctionsRefuses() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())

        #expect(throws: MeshRefusal.pass) { try MeshRender(device: device, pass: "#include <metal_stdlib>\n") }
    }

    /// A Guide carries the refusal out as the mesh case, which a consumer reads rather than receiving a Guide that displaces nothing and says nothing.
    @Test func theRefusalIsReadableWhereTheConsumerReceivesIt() {
        let refusal = GuideRefusal.mesh(.target(columns: 20_000, rows: 8))

        guard case let .mesh(pass) = refusal else {
            #expect(Bool(false), "a mesh source refuses as the mesh case")
            return
        }

        #expect(pass == .target(columns: 20_000, rows: 8))
    }
}
