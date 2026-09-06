/// The texel lattice an epsilon demands of a Frame. A read snaps to the containing texel, so half a texel diagonal is the worst a read is out by, and a texel wider than that lets a vert chatter around a target the field cannot locate as precisely as the vert is settling.
struct FieldResolution: Sendable {
    /// Texels across the wider axis past which a bake is refused on cost long before it is baked, here so an epsilon near zero yields a count rather than trapping the conversion.
    static let ceiling = 1 << 16

    let frame: Frame
    let settleEpsilon: Float
    /// Texels across the wider axis of the Frame. The other axis takes the count its share of the Frame rounds to.
    let count: Int
    let columns: Int
    let rows: Int

    init(frame: Frame, settleEpsilon: Float) {
        self.frame = frame
        self.settleEpsilon = settleEpsilon

        // Half a texel diagonal held within the epsilon, which on a square texel is a side of the epsilon times root two.
        let span = max(frame.size.x, frame.size.y)
        let demand = (Double(span) / (Double(settleEpsilon) * 2.0.squareRoot())).rounded(.up)
        guard settleEpsilon > 0, frame.size.x > 0, frame.size.y > 0, demand >= 1 else {
            count = 0
            columns = 0
            rows = 0
            return
        }

        let texels = demand < Double(Self.ceiling) ? Int(demand) : Self.ceiling
        count = texels
        columns = max(1, Int((frame.size.x / span * Float(texels)).rounded()))
        rows = max(1, Int((frame.size.y / span * Float(texels)).rounded()))
    }

    var texels: Int {
        columns * rows
    }

    /// The derivation run backwards, so a count the budget affords can be reported to the consumer as the epsilon it answers. Nudged off the boundary of the count's band, which narrows to a Float that derives one texel finer as often as not.
    static func epsilon(count: Int, frame: Frame) -> Float {
        guard count > 0 else { return .infinity }
        let span = max(frame.size.x, frame.size.y)
        return Float(Double(span) / (Double(count) * 2.0.squareRoot())).nextUp
    }
}
