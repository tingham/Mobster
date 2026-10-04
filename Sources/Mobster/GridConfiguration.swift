public struct GridConfiguration: PresetConfiguration {
    public let parameters: GridPreset

    public init(parameters: GridPreset) {
        self.parameters = parameters
    }

    public func lines(in frame: Frame) throws(MeshRefusal) -> [Line] {
        parameters.paths(in: frame)
    }
}
