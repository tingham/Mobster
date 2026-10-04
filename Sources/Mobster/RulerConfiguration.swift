public struct RulerConfiguration: PresetConfiguration {
    public let parameters: RulerPreset

    public init(parameters: RulerPreset) {
        self.parameters = parameters
    }

    public func lines(in frame: Frame) throws(MeshRefusal) -> [Line] {
        parameters.paths(in: frame)
    }
}
