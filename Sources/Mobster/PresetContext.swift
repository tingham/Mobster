import Metal

/// What producing a guide's paths requires and its parameters do not carry. One of these serves every guide type built from a mesh, and a guide type plotted analytically takes none. It does not serialize: the device is a reference where a parameter is a value, so a consumer stores the parameters and builds this again each time it produces.
public struct PresetContext: Sendable {
    /// Taken from the extraction's own answer rather than restated, so the package holds one count and not two.
    public static let fit = MeshExtraction.fit

    public let device: any MTLDevice
    /// Locations each extracted boundary is fitted to.
    public let fit: Int
    public let perspective: MeshPerspective

    public init(device: any MTLDevice, fit: Int, perspective: MeshPerspective) {
        self.device = device
        self.fit = fit
        self.perspective = perspective
    }
}
