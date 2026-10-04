public struct ColumnsConfiguration: PresetConfiguration {
    public let parameters: ColumnsPreset

    public init(parameters: ColumnsPreset) {
        self.parameters = parameters
    }

    public func lines(in frame: Frame) throws(MeshRefusal) -> [Line] {
        parameters.paths(in: frame)
    }
}
