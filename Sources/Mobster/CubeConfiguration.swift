public struct CubeConfiguration: PresetConfiguration {
    public let parameters: CubeMesh
    public let context: PresetContext

    public init(parameters: CubeMesh, context: PresetContext) {
        self.parameters = parameters
        self.context = context
    }

    public func lines(in frame: Frame) throws(MeshRefusal) -> [Line] {
        try MeshExtraction(mesh: parameters.mesh(in: frame), frame: frame, fit: context.fit, perspective: context.perspective).paths(device: context.device)
    }
}
