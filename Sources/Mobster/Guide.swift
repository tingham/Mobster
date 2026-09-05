public final class Guide {
    /// Scene units. A point within this of its target has arrived.
    public static let settleEpsilon: Float = 1

    /// Nil until initialize is called; no workload may run before that.
    private(set) var frame: Frame?
    private(set) var field: Field?
    private(set) var tokens: [PointIdentifier: Token] = [:]
    /// Membership order, so what a play returns does not follow the hashing of the identifiers.
    private(set) var membership: [PointIdentifier] = []
    public var adherence: Adherence
    private var listeners: [() -> Void] = []

    public init(adherence: Adherence) {
        self.adherence = adherence
    }

    public func initialize(frame: Frame, membership strokes: [Stroke] = [], time: Double = 0) {
        self.frame = frame
        tokens = [:]
        membership = []
        tokenize(membership: strokes, time: time)
    }

    /// A point already carrying a token keeps it, so a stroke redelivered whole does not restart the segments of the points it already had.
    public func tokenize(membership strokes: [Stroke], time: Double) {
        for stroke in strokes {
            for sample in stroke.samples {
                guard tokens[sample.identifier] == nil else { continue }
                membership.append(sample.identifier)
                tokens[sample.identifier] = Token(
                    point: sample.identifier,
                    stroke: stroke.identifier,
                    location: sample.location,
                    target: target(for: sample.location),
                    origin: time
                )
            }
        }
    }

    /// The segment in flight ends here and the next one starts from wherever the point actually is, rather than from where it set out.
    public func update(field: Field, time: Double) {
        self.field = field

        for identifier in membership {
            guard var token = tokens[identifier] else { continue }
            token.target = target(for: token.location)
            token.origin = time
            tokens[identifier] = token
        }
    }

    public func play(speed: Float, time: Double) -> GuideAdvance {
        var displacements: [GuideDisplacement] = []
        var arrivals = 0
        var pending = 0

        for identifier in membership {
            guard var token = tokens[identifier] else { continue }
            let departure = token.location
            let arrived = settled(token)
            token.location = advanced(token, speed: speed, time: time)
            token.origin = time
            tokens[identifier] = token

            if settled(token) {
                if !arrived { arrivals += 1 }
            } else {
                pending += 1
            }

            guard token.location != departure else { continue }
            displacements.append(GuideDisplacement(
                point: token.point,
                stroke: token.stroke,
                location: token.location,
                rect: GuideRect(covering: departure, token.location)
            ))
        }

        // Answered from the counts the pass already produced, so no settled state is kept and no second walk is taken to read it.
        if arrivals > 0, pending == 0 {
            for listener in listeners { listener() }
        }

        return GuideAdvance(displacements: displacements)
    }

    public func addSettleListener(_ listener: @escaping () -> Void) {
        listeners.append(listener)
    }

    private func target(for location: SIMD2<Float>) -> SIMD2<Float> {
        guard let field else { return location }
        return adherence.target(for: location, in: field)
    }

    /// Constant speed along the run that remains. A time before the origin advances nothing rather than running the segment backwards.
    private func advanced(_ token: Token, speed: Float, time: Double) -> SIMD2<Float> {
        let run = token.target - token.location
        let remaining = length(run)
        guard remaining > 0 else { return token.location }

        let elapsed = max(time - token.origin, 0)
        let travel = min(speed * Float(elapsed), remaining)
        guard travel > 0 else { return token.location }
        return token.location + run / remaining * travel
    }

    private func settled(_ token: Token) -> Bool {
        length(token.target - token.location) <= Self.settleEpsilon
    }

    private func length(_ run: SIMD2<Float>) -> Float {
        (run.x * run.x + run.y * run.y).squareRoot()
    }
}
