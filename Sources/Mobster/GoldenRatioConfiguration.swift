public struct GoldenRatioConfiguration: PresetConfiguration {
    public let parameters: GoldenRatioPreset

    public init(parameters: GoldenRatioPreset) {
        self.parameters = parameters
    }

    public func lines(in frame: Frame) throws(MeshRefusal) -> [Line] {
        parameters.paths(in: frame)
    }
}
