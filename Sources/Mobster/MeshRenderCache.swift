import Metal
import Synchronization

/// The one identity pass a device ever compiles. Compiling it per construction cost a hundred and sixteen milliseconds the first time and forty eight after, which on a slider drag is felt.
final class MeshRenderCache: Sendable {
    static let shared = MeshRenderCache()

    private let compiled = Mutex<[ObjectIdentifier: MeshRender]>([:])

    private init() {}

    /// The compile happens under the lock, so two callers arriving together share one pass rather than each building one and the later overwriting the earlier. A device that refused is asked again rather than having its refusal remembered, a refusal being a condition of the device and not a property of the pass.
    func render(device: any MTLDevice) throws(MeshRefusal) -> MeshRender {
        let key = ObjectIdentifier(device)

        return try compiled.withLock { (compiled: inout [ObjectIdentifier: MeshRender]) throws(MeshRefusal) -> MeshRender in
            if let standing = compiled[key] { return standing }

            let built = try MeshRender(device: device)
            compiled[key] = built

            return built
        }
    }
}
