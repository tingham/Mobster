import Metal
import Testing
@testable import Mobster

struct MeshRenderCacheTests {
    /// A pass compiled per construction cost a hundred and sixteen milliseconds the first time and forty eight after, so what the cache has to hold is the same pass and not an equivalent one.
    @Test func aDeviceCompilesThePassOnce() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let first = try MeshRenderCache.shared.render(device: device)
        let second = try MeshRenderCache.shared.render(device: device)

        #expect(first === second)
    }
}
