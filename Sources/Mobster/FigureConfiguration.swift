public struct FigureConfiguration: PresetConfiguration {
    public let parameters: FigurePreset
    public let context: PresetContext

    public init(parameters: FigurePreset, context: PresetContext) {
        self.parameters = parameters
        self.context = context
    }

    /// The break lines measure the figure rather than belonging to it, so they are appended as paths after the extracted boundaries.
    public func lines(in frame: Frame) throws(MeshRefusal) -> [Line] {
        let extracted = try MeshExtraction(mesh: parameters.mesh(in: frame), frame: frame, fit: context.fit, perspective: context.perspective).paths(device: context.device)

        return extracted + parameters.breakLines(in: frame)
    }
}
