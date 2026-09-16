import Foundation

/// The field of view a construction is projected through. A form pointing toward the viewer foreshortens by it, which an orthographic projection does not show at all.
public struct MeshPerspective: Hashable, Sendable {
    /// Degrees. The cone of vision a drawing stays inside before it reads as distorted, which makes it the convention rather than a chosen number.
    public static let opening: Float = 60
    /// Degrees. Below the lesser bound the projection is the orthographic one it replaces and above the greater the near of a form swells into a fisheye, so both cases are removed rather than answered.
    public static let range: ClosedRange<Float> = 20 ... 90

    /// Degrees, held within the range that reads.
    public let fieldOfView: Float

    public init(fieldOfView: Float = MeshPerspective.opening) {
        self.fieldOfView = min(max(fieldOfView, Self.range.lowerBound), Self.range.upperBound)
    }

    /// The remove the construction is viewed from, standing in front of its nearest location. It follows from the field of view and the construction's own transverse bounds, the construction subtending the field exactly, so nothing else is dialled and a construction that fitted the Frame still fits it.
    func distance(across: Float) -> Float {
        across / 2 / tan(fieldOfView / 2 * .pi / 180)
    }

    /// What a location standing this far behind the nearest one is magnified by. The nearest keeps the place the orthographic projection gave it and everything behind pulls in toward the construction's own axis, which is why nothing grows past the Frame.
    func magnification(behind: Float, across: Float) -> Float {
        let remove = distance(across: across)

        return remove > 0 ? remove / (remove + behind) : 1
    }
}
