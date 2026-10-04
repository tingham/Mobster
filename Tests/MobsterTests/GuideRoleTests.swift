import Testing
@testable import Mobster

struct GuideRoleTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
    /// Near the far side of the Frame, so a bake that took the construction would carry it the twelve units right instead of the eighty four left.
    private let placed = SIMD2<Float>(100, 64)

    private func line(x: Float, role: PathRole) -> Line {
        Line(verts: [Vert(location: SIMD2<Float>(x, 0)), Vert(location: SIMD2<Float>(x, 128))], role: role)
    }

    private func initialized(_ source: GuideSource) throws -> Guide {
        let guide = Guide(frame: frame)
        try guide.initialize(source: source, frame: frame, adhesion: 1, duration: 1, settleEpsilon: 1, budget: .max)

        return guide
    }

    /// A field with no location vends no grayscale, and a vert reading it has nowhere to be carried.
    @Test func aSourceOfConstructionAloneBakesAFieldHoldingNoPathLocation() throws {
        let guide = try initialized(.lines([line(x: 16, role: .construction), line(x: 112, role: .construction)]))
        let settled = guide.evaluate([Line(verts: [Vert(location: placed)])], at: 1)

        #expect(guide.raster() == nil)
        #expect(settled[0].verts[0].location == placed)
    }

    /// Golden Ratio is the preset that carries both, and its quadlines stand nearer the eye than the spiral does.
    @Test func aPresetSourceBakesItsFormAndNotItsConstruction() throws {
        let guide = try initialized(.preset(GoldenRatioPreset()))
        let spiral = try initialized(.preset(GoldenRatioPreset(quadlines: false)))

        #expect(guide.lines.count > spiral.lines.count)
        #expect(guide.evaluate([Line(verts: [Vert(location: placed)])], at: 1)[0].verts[0].location == spiral.evaluate([Line(verts: [Vert(location: placed)])], at: 1)[0].verts[0].location)
    }

    @Test func aVertIsCarriedToTheFormItStandsFurthestFrom() throws {
        let guide = try initialized(.lines([line(x: 16, role: .form), line(x: 112, role: .construction)]))
        let settled = guide.evaluate([Line(verts: [Vert(location: placed)])], at: 1)[0].verts[0].location

        #expect(abs(settled.x - 16) < 2)
        #expect(abs(settled.y - placed.y) < 2)
    }

    /// Construction is kept out of the bake and not out of the vend, which is what a consumer draws it from.
    @Test func theConstructionAGuideDoesNotBakeIsStillVendedWithItsRole() throws {
        let guide = try initialized(.lines([line(x: 16, role: .form), line(x: 112, role: .construction)]))

        #expect(guide.lines.count == 2)
        #expect(guide.lines[0].role == .form)
        #expect(guide.lines[1].role == .construction)
    }

    /// Evaluate displaces verts, and an attribute the consumer declared on the line is not the Guide's to reset.
    @Test func evaluateReturnsTheRoleItWasGiven() throws {
        let guide = try initialized(.lines([line(x: 16, role: .form)]))
        let content = [Line(verts: [Vert(location: placed)], identifier: LineIdentifier(9), role: .construction),
                       Line(verts: [Vert(location: placed)])]
        let settled = guide.evaluate(content, at: 1)

        #expect(settled[0].role == .construction)
        #expect(settled[0].identifier == LineIdentifier(9))
        #expect(settled[1].role == .form)
    }

    /// A vert standing on a break line is carried past it to the form, the break lines being marks the figure is measured by.
    @Test func aFiguresBreakLineAttractsNothing() throws {
        let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(800, 800))
        let measured = FigurePreset(sex: .male,
                                    heads: 8,
                                    target: SIMD3<Float>(0, 0, 1),
                                    headTarget: SIMD3<Float>(0, 0, 1),
                                    leftHand: SIMD2<Float>(0.31, 0.5),
                                    rightHand: SIMD2<Float>(0.69, 0.5),
                                    leftFoot: SIMD2<Float>(0.42, 1),
                                    rightFoot: SIMD2<Float>(0.58, 1),
                                    headLines: true).breakLines(in: square)
        let standing = try #require(measured.first?.verts.first?.location)
        let form = Line(verts: [Vert(location: SIMD2<Float>(16, 0)), Vert(location: SIMD2<Float>(16, 800))], role: .form)
        let guide = Guide(frame: square)
        try guide.initialize(source: .lines([form] + measured), frame: square, adhesion: 1, duration: 1, settleEpsilon: 4, budget: .max)
        let settled = guide.evaluate([Line(verts: [Vert(location: standing)])], at: 1)[0].verts[0].location

        #expect(guide.lines.count == measured.count + 1)
        #expect(abs(settled.x - 16) < 5)
    }

    @Test func theRolesOfAPresetSurviveVending() throws {
        let guide = try initialized(.preset(GoldenRatioPreset()))

        #expect(guide.lines[0].role == .form)
        #expect(guide.lines.dropFirst().allSatisfy { $0.role == .construction })
    }
}
