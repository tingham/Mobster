public struct ThirdsConfiguration: PresetConfiguration {
    public let parameters: ThirdsPreset

    public init(parameters: ThirdsPreset) {
        self.parameters = parameters
    }

    public func lines(in frame: Frame) throws(MeshRefusal) -> [Line] {
        parameters.paths(in: frame)
    }
}
