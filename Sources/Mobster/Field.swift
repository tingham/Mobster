/// The nearest path location for every texel of a Frame. It holds no distance; a distance is recovered at read time from the location it holds.
public struct Field: Sendable {
    public let frame: Frame
    public let columns: Int
    public let rows: Int
    /// Row major, one nearest path location per texel. Empty where nothing was baked.
    public let locations: [SIMD2<Float>]

    public init(frame: Frame, columns: Int, rows: Int, locations: [SIMD2<Float>]) {
        self.frame = frame
        self.columns = columns
        self.rows = rows
        self.locations = locations
    }

    public func distance(at location: SIMD2<Float>) -> Float {
        guard let nearest = nearest(at: location) else { return .infinity }
        let run = nearest - location
        return (run.x * run.x + run.y * run.y).squareRoot()
    }

    /// Zero where the location coincides with the location the field holds, which has no direction to report.
    public func direction(at location: SIMD2<Float>) -> SIMD2<Float> {
        guard let nearest = nearest(at: location) else { return SIMD2<Float>(0, 0) }
        let run = nearest - location
        let length = (run.x * run.x + run.y * run.y).squareRoot()
        guard length > 0 else { return SIMD2<Float>(0, 0) }
        return run / length
    }

    /// An approximation for display, scaled so the greatest distance the field carries is black and a path is white. It is not the storage format.
    public func grayscale() -> FieldRaster {
        guard !locations.isEmpty else {
            return FieldRaster(columns: columns, rows: rows, samples: [UInt8](repeating: 0, count: columns * rows))
        }

        let distances = (0 ..< rows).flatMap { row in
            (0 ..< columns).map { column -> Float in
                let center = center(column: column, row: row)
                let run = locations[row * columns + column] - center
                return (run.x * run.x + run.y * run.y).squareRoot()
            }
        }

        let ceiling = distances.max() ?? 0
        guard ceiling > 0 else {
            return FieldRaster(columns: columns, rows: rows, samples: [UInt8](repeating: 255, count: columns * rows))
        }

        return FieldRaster(columns: columns, rows: rows, samples: distances.map { distance in
            UInt8((255 * (1 - distance / ceiling)).rounded())
        })
    }

    /// The scene location of the centre of a texel.
    func center(column: Int, row: Int) -> SIMD2<Float> {
        let texel = frame.size / SIMD2<Float>(Float(columns), Float(rows))
        return frame.origin + SIMD2<Float>(Float(column) + 0.5, Float(row) + 0.5) * texel
    }

    /// A location beyond the Frame reads the texel it lies nearest, so a point outside still resolves toward a path.
    private func nearest(at location: SIMD2<Float>) -> SIMD2<Float>? {
        guard !locations.isEmpty else { return nil }

        let texel = frame.size / SIMD2<Float>(Float(columns), Float(rows))
        let offset = (location - frame.origin) / texel
        let column = min(max(Int(offset.x.rounded(.down)), 0), columns - 1)
        let row = min(max(Int(offset.y.rounded(.down)), 0), rows - 1)

        return locations[row * columns + column]
    }
}
