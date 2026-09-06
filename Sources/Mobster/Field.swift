/// The nearest path location for every texel of a Frame. It holds no distance; a distance is recovered at read time from the location it holds.
public struct Field: Sendable {
    public let frame: Frame
    public let columns: Int
    public let rows: Int
    /// Row major, one nearest path location per texel.
    public let locations: [SIMD2<Float>]

    public init(frame: Frame, columns: Int, rows: Int, locations: [SIMD2<Float>]) {
        self.frame = frame
        self.columns = columns
        self.rows = rows
        self.locations = locations
    }

    /// The texel counts stand whether or not the bake found a path, so emptiness is reported rather than inferred from them.
    public var isEmpty: Bool {
        locations.isEmpty
    }

    public func distance(at location: SIMD2<Float>) -> Float {
        guard let nearest = nearest(at: location) else { return .infinity }
        return length(nearest - location)
    }

    /// Zero where the location coincides with the location the field holds, which has no direction to report.
    public func direction(at location: SIMD2<Float>) -> SIMD2<Float> {
        guard let nearest = nearest(at: location) else { return SIMD2<Float>(0, 0) }
        let run = nearest - location
        let reach = length(run)
        guard reach > 0 else { return SIMD2<Float>(0, 0) }
        return run / reach
    }

    /// An approximation for display, scaled so the greatest distance the field carries is black and a path is white. It is not the storage format. Nil for an empty field, which has no scale and would render as a legitimate field at uniform maximum distance.
    public func grayscale() -> FieldRaster? {
        guard !isEmpty else { return nil }

        let grid = FieldGrid(frame: frame, columns: columns, rows: rows)
        let distances = (0 ..< rows).flatMap { row in
            (0 ..< columns).map { column in
                length(locations[grid.slot(column: column, row: row)] - grid.center(column: column, row: row))
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

    private func nearest(at location: SIMD2<Float>) -> SIMD2<Float>? {
        guard !isEmpty else { return nil }
        return locations[FieldGrid(frame: frame, columns: columns, rows: rows).slot(at: location)]
    }

    private func length(_ run: SIMD2<Float>) -> Float {
        (run.x * run.x + run.y * run.y).squareRoot()
    }
}
