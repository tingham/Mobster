public struct CurveConfiguration: PresetConfiguration {
    public let parameters: CurvePreset

    public init(parameters: CurvePreset) {
        self.parameters = parameters
    }

    public func lines(in frame: Frame) throws(MeshRefusal) -> [Line] {
        parameters.paths(in: frame)
    }
}
