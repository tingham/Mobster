import Metal
import Mobster
import Testing

/// What a consumer reaches when it names a guide type, read through the public surface rather than through a testable import, because the point of a configuration is what a consumer can get to without assembling anything itself.
struct PresetConfigurationTests {
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    /// Straight out of the chest, which is the frontal view.
    private let frontal = SIMD3<Float>(0, 0, 1)
    /// Down the body diagonal, which is the view three faces of the box read from.
    private let diagonal = SIMD3<Float>(1, Float(3).squareRoot(), Float(2).squareRoot())

    /// Every plate in the roster produces its paths through the one declaration, so a picker driven by the roster offers nothing a consumer has to finish building.
    @Test func everyRosterCaseVendsLines() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())

        for kind in PresetKind.allCases {
            let lines = try configuration(kind, device: device).lines(in: square)

            #expect(!lines.isEmpty)
            #expect(lines.allSatisfy { !$0.verts.isEmpty })
        }
    }

    /// Golden Ratio declares its spiral form and its rectangles construction, and Thirds declares everything it plots form.
    @Test func aPlottedConfigurationCarriesTheRolesItsGuideTypeDeclares() throws {
        let spiral = try GoldenRatioConfiguration(parameters: GoldenRatioPreset(focus: GoldenRatioPreset.focus, quadlines: GoldenRatioPreset.quadlines)).lines(in: square)
        let thirds = try ThirdsConfiguration(parameters: ThirdsPreset()).lines(in: square)

        #expect(spiral.count > 1)
        #expect(spiral.first?.role == .form)
        #expect(spiral.dropFirst().allSatisfy { $0.role == .construction })
        #expect(thirds.count == 4)
        #expect(thirds.allSatisfy { $0.role == .form })
    }

    /// A figure carries whatever role the extraction declared for each boundary, then its head breaks as construction, which the consumer no longer appends for itself.
    @Test func anExtractedConfigurationCarriesTheRolesItsGuideTypeDeclares() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let parameters = figure(headLines: true)
        let breaks = parameters.breakLines(in: square)
        let extracted = try MeshExtraction(mesh: parameters.mesh(in: square), frame: square, fit: PresetContext.fit, perspective: MeshPerspective(fieldOfView: MeshPerspective.opening)).paths(device: device)
        let lines = try FigureConfiguration(parameters: parameters, context: context(device)).lines(in: square)

        #expect(!breaks.isEmpty)
        #expect(breaks.allSatisfy { $0.role == .construction })
        #expect(lines.contains { $0.role == .form })
        #expect(lines.map(\.role) == extracted.map(\.role) + breaks.map(\.role))
    }

    private func context(_ device: any MTLDevice) -> PresetContext {
        PresetContext(device: device, fit: PresetContext.fit, perspective: MeshPerspective(fieldOfView: MeshPerspective.opening))
    }

    private func figure(headLines: Bool) -> FigurePreset {
        FigurePreset(sex: .male,
                     heads: 8,
                     target: frontal,
                     roll: 0,
                     headTarget: frontal,
                     leftHand: SIMD2<Float>(0.1, 0.5),
                     rightHand: SIMD2<Float>(0.9, 0.5),
                     leftFoot: SIMD2<Float>(0.4, 1),
                     rightFoot: SIMD2<Float>(0.6, 1),
                     headLines: headLines)
    }

    /// The switch is exhaustive, so a plate added to the roster fails to compile here until it has a configuration to be reached through.
    private func configuration(_ kind: PresetKind, device: any MTLDevice) -> any PresetConfiguration {
        switch kind {
        case .goldenRatio:
            return GoldenRatioConfiguration(parameters: GoldenRatioPreset(focus: GoldenRatioPreset.focus, quadlines: GoldenRatioPreset.quadlines))
        case .thirds:
            return ThirdsConfiguration(parameters: ThirdsPreset())
        case .columns:
            return ColumnsConfiguration(parameters: ColumnsPreset(count: 4, gutter: 0.02))
        case .rows:
            return RowsConfiguration(parameters: RowsPreset(count: 4, gutter: 0.02))
        case .grid:
            return GridConfiguration(parameters: GridPreset(count: 4, gutter: 0.02))
        case .ruler:
            return RulerConfiguration(parameters: RulerPreset(center: SIMD2<Float>(0.5, 0.5), firstDegree: 0, secondDegree: 180, distance: 0.1))
        case .curve:
            return CurveConfiguration(parameters: CurvePreset(center: SIMD2<Float>(0.5, 0.5), firstDegree: 0, secondDegree: 180, distance: 0.1, control: SIMD2<Float>(0.5, 0.25), resolution: 32))
        case .head:
            return HeadConfiguration(parameters: HeadPreset(sex: .male, target: SIMD3<Float>(1, 0, 1), roll: 0), context: context(device))
        case .figure:
            return FigureConfiguration(parameters: figure(headLines: true), context: context(device))
        case .cube:
            return CubeConfiguration(parameters: CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: diagonal, roll: 0), context: context(device))
        }
    }
}
