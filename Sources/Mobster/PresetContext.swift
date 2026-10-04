import Metal

/// What producing a guide's paths requires and its parameters do not carry. One of these serves every guide type built from a mesh, and a guide type plotted analytically takes none. It does not serialize: the device is a reference where a parameter is a value, so a consumer stores the parameters and builds this again each time it produces.
public struct PresetContext: Sendable {
    public let device: any MTLDevice
    /// Locations each extracted boundary is fitted to, which `MeshExtraction.fit` is the package's answer for.
    public let fit: Int
    public let perspective: MeshPerspective

    public init(device: any MTLDevice, fit: Int, perspective: MeshPerspective) {
        self.device = device
        self.fit = fit
        self.perspective = perspective
    }
}
