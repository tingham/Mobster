/// Even divisions of an extent separated by gutters. A gutter is a band, so each interior gutter contributes two edges and never one.
struct PresetGutter {
    let count: Int
    let gutter: Float
    let extent: Float

    func edges() -> [Float] {
        guard count > 1 else { return [] }

        let division = (extent - Float(count - 1) * gutter) / Float(count)
        let stride = division + gutter

        return (0 ..< count - 1).flatMap { index -> [Float] in
            let leading = Float(index) * stride + division
            return [leading, leading + gutter]
        }
    }
}
