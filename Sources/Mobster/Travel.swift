import Foundation

/// How far along its travel a vert stands at a supplied progress, shaped by the attributes that vert carries.
struct Travel {
    /// Nil is the plain travel rather than a weight of zero, so an absent attribute and a supplied zero cannot meet on one path.
    let mass: Float?
    /// Nil is the plain travel rather than a resistance of zero.
    let drag: Float?

    init(mass: Float?, drag: Float?) {
        self.mass = mass
        self.drag = drag
    }

    /// The ends are answered before either shape is reached, so arrival at the duration survives whatever the attributes ask for.
    func fraction(at progress: Float) -> Float {
        guard progress > 0 else { return 0 }
        guard progress < 1 else { return 1 }

        var carried = progress
        if let mass {
            carried = weighted(carried, mass: mass)
        }
        if let drag {
            carried = resisted(carried, drag: drag)
        }
        return carried
    }

    /// The exponent is the weight itself, so a heavier vert trails a lighter one at every moment of the run and a weightless one stands on its target throughout it.
    private func weighted(_ progress: Float, mass: Float) -> Float {
        pow(progress, max(mass, 0))
    }

    /// A resistance of one is spent, a resistance of zero holds the vert back against the whole run, and a resistance of minus one leads it away before it returns.
    private func resisted(_ progress: Float, drag: Float) -> Float {
        let resistance = min(max(drag, -1), 1)
        return progress * (progress + resistance * (1 - progress))
    }
}
