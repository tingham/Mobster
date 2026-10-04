public struct RowsConfiguration: PresetConfiguration {
    public let parameters: RowsPreset

    public init(parameters: RowsPreset) {
        self.parameters = parameters
    }

    public func lines(in frame: Frame) throws(MeshRefusal) -> [Line] {
        parameters.paths(in: frame)
    }
}
