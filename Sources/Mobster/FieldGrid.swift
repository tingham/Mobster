/// The texel lattice a field is baked and read on. The mapping between a scene location and a texel index lives here alone, so a bake and a read cannot drift apart.
struct FieldGrid: Sendable {
    let frame: Frame
    let columns: Int
    let rows: Int

    /// Rounding the counts leaves a texel square only where the aspect ratio of the Frame divides the derived count evenly.
    var texel: SIMD2<Float> {
        frame.size / SIMD2<Float>(Float(columns), Float(rows))
    }

    func center(column: Int, row: Int) -> SIMD2<Float> {
        frame.origin + SIMD2<Float>(Float(column) + 0.5, Float(row) + 0.5) * texel
    }

    func column(at position: Float) -> Int {
        index((position - frame.origin.x) / texel.x, count: columns)
    }

    func row(at position: Float) -> Int {
        index((position - frame.origin.y) / texel.y, count: rows)
    }

    func slot(column: Int, row: Int) -> Int {
        row * columns + column
    }

    /// A location beyond the Frame takes the texel it lies nearest rather than wrapping onto the far side.
    func slot(at location: SIMD2<Float>) -> Int {
        slot(column: column(at: location.x), row: row(at: location.y))
    }

    /// Clamped before the conversion, because a location far outside the Frame or a degenerate texel yields an offset an integer cannot hold.
    private func index(_ offset: Float, count: Int) -> Int {
        guard offset > 0 else { return 0 }
        guard offset < Float(count) else { return count - 1 }
        return min(Int(offset), count - 1)
    }
}
