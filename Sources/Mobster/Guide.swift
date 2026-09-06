public final class Guide {
    /// Supplied at construction, so there is no window in which a workload precedes it.
    public private(set) var frame: Frame
    private(set) var field: Field?
    private(set) var tokens: [PointIdentifier: Token] = [:]
    /// Membership order, so what a play returns does not follow the hashing of the identifiers.
    private(set) var membership: [PointIdentifier] = []
    public private(set) var adherence: Adherence
    /// Scene units. Supplied rather than fixed here, because what a pixel is worth in the scene is the consumer's to know.
    public var settleEpsilon: Float
    private var listeners: [() -> Void] = []
    /// How many tokens the pass before this one found short of their targets, and nil where no pass has been taken. It records what was observed, not what any token is.
    private var short: Int?

    public init(frame: Frame, adherence: Adherence, settleEpsilon: Float) {
        self.frame = frame
        self.adherence = adherence
        self.settleEpsilon = settleEpsilon
    }

    public func initialize(frame: Frame, membership strokes: [Stroke] = [], time: Double = 0) {
        self.frame = frame
        tokens = [:]
        membership = []
        short = nil
        tokenize(membership: strokes, time: time)
    }

    /// The reach at which every point in the Frame settles within the epsilon. The worst case is the diagonal, a point in one corner of the Frame whose nearest path location is the far corner.
    public var fullAdherenceReach: Float {
        Adherence.reach(settling: length(frame.size), within: settleEpsilon)
    }

    /// A point already carrying a token keeps it, so a stroke redelivered whole does not restart the segments of the points it already had.
    public func tokenize(membership strokes: [Stroke], time: Double) {
        let observed = short
        var pending = observed ?? 0

        for stroke in strokes {
            for sample in stroke.samples {
                guard tokens[sample.identifier] == nil else { continue }
                membership.append(sample.identifier)
                let token = Token(
                    point: sample.identifier,
                    stroke: stroke.identifier,
                    location: sample.location,
                    target: target(for: sample.location),
                    origin: time
                )
                tokens[sample.identifier] = token
                if !settled(token) { pending += 1 }
            }
        }

        announce(pending, observed: observed)
    }

    /// The segment in flight ends here and the next one starts from wherever the point actually is, rather than from where it set out.
    public func update(field: Field, time: Double) {
        self.field = field
        resolve(time: time)
    }

    /// Baking here is what a stroke event on the source layer lands on, since paths are what such an event yields and a caller with no field of its own has nothing else to hand over. The bake resolves against the epsilon the Guide already settles within, so no resolution crosses the boundary.
    public func update(paths: [[SIMD2<Float>]], budget: Int, time: Double) throws(FieldRefusal) {
        update(field: try FieldBake(paths: paths, frame: frame, settleEpsilon: settleEpsilon, budget: budget).field(), time: time)
    }

    /// The dial moved every target, so it ends the segment in flight exactly as a field change does.
    public func update(adherence: Adherence, time: Double) {
        self.adherence = adherence
        resolve(time: time)
    }

    public func play(speed: Float, time: Double) -> GuideAdvance {
        let observed = short
        var displacements: [GuideDisplacement] = []
        var pending = 0

        for identifier in membership {
            guard var token = tokens[identifier] else { continue }
            let departure = token.location
            token.location = advanced(token, speed: speed, time: time)
            tokens[identifier] = token
            // Read after the move, so the play that carries a point the last epsilon onto its target is the play that settles it.
            if !settled(token) { pending += 1 }

            guard token.location != departure else { continue }
            displacements.append(GuideDisplacement(
                point: token.point,
                stroke: token.stroke,
                location: token.location,
                rect: GuideRect(covering: departure, token.location)
            ))
        }

        announce(pending, observed: observed)
        return GuideAdvance(displacements: displacements)
    }

    /// A listener joining a membership the last pass found settled hears it now, because the condition it exists to answer has already begun and the next entry into it may never come.
    public func addSettleListener(_ listener: @escaping () -> Void) {
        listeners.append(listener)
        if short == 0 { listener() }
    }

    /// Every target resolves again from where its point actually is, and the new segment is dated from this moment.
    private func resolve(time: Double) {
        let observed = short
        var pending = 0

        for identifier in membership {
            guard var token = tokens[identifier] else { continue }
            token.anchor = token.location
            token.target = target(for: token.location)
            token.origin = time
            tokens[identifier] = token
            if !settled(token) { pending += 1 }
        }

        announce(pending, observed: observed)
    }

    /// What this pass counted against what the last one did, so the notification lands on the pass that enters the condition. The counts come from the walk the pass already takes.
    private func announce(_ pending: Int, observed: Int?) {
        short = pending
        guard pending == 0, observed != 0 else { return }
        for listener in listeners { listener() }
    }

    private func target(for location: SIMD2<Float>) -> SIMD2<Float> {
        guard let field else { return location }
        return adherence.target(for: location, in: field)
    }

    /// Constant speed from where the segment began, so a time yields the same location whatever times came before it. A time before the origin leaves the point where the segment started.
    private func advanced(_ token: Token, speed: Float, time: Double) -> SIMD2<Float> {
        let run = token.target - token.anchor
        let remaining = length(run)
        guard remaining > 0 else { return token.anchor }

        let travel = min(speed * Float(time - token.origin), remaining)
        guard travel > 0 else { return token.anchor }
        return token.anchor + run / remaining * travel
    }

    /// Strictly within, so a point exactly an epsilon out has not arrived and the play that carries it onto its target is the one that settles it.
    private func settled(_ token: Token) -> Bool {
        length(token.target - token.location) < settleEpsilon
    }

    private func length(_ run: SIMD2<Float>) -> Float {
        (run.x * run.x + run.y * run.y).squareRoot()
    }
}
