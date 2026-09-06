import Testing
@testable import Mobster

struct ValueSemanticsTests {
    @Test func vertIsAStruct() {
        let vert = Vert(location: SIMD2<Float>(10, 20), identifier: VertIdentifier(1))

        #expect(Mirror(reflecting: vert).displayStyle == .struct)
    }

    @Test func lineIsAStruct() {
        let line = Line(verts: [], identifier: LineIdentifier(9))

        #expect(Mirror(reflecting: line).displayStyle == .struct)
    }

    @Test func frameIsAStruct() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 200))

        #expect(Mirror(reflecting: frame).displayStyle == .struct)
    }
}
