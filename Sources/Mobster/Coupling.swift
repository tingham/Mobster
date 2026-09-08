import Foundation

/// The time offsets the couplings along one line impose on that line's verts at a supplied progress. An offset carries a vert further along its own travel; it does not carry it toward the coupled vert's target.
struct Coupling {
    /// Per vert, as supplied. A nil emits nothing and is held as a nil, so an absent coupling and a supplied zero never meet on one path.
    let strengths: [Float?]
    /// Per vert, how far that vert stands along its own travel, which is the motion its peers take a share of.
    let fractions: [Float]

    init(strengths: [Float?], fractions: [Float]) {
        self.strengths = strengths
        self.fractions = fractions
    }

    /// Both ends of the run answer zero, so nothing is offset before the run opens and every vert is home at the duration whichever sign the offsets carry.
    func offsets(at progress: Float) -> [Float] {
        let remaining = 1 - progress
        guard progress > 0, remaining > 0 else { return [Float](repeating: 0, count: strengths.count) }

        return strengths.indices.map { gathered(at: $0) * remaining }
    }

    /// Gathered by ascending hop with the two sides added as a pair, so the same additions land in the same order whichever way the line is walked.
    private func gathered(at index: Int) -> Float {
        var carried: Float = 0
        for hop in 1 ..< strengths.count {
            carried += contribution(from: index - hop, hops: hop) + contribution(from: index + hop, hops: hop)
        }
        return carried
    }

    /// The magnitude decays by the coupling at each hop while the sign is held, so a negative coupling opposes at every distance rather than alternating with the hop count.
    private func contribution(from source: Int, hops: Int) -> Float {
        guard strengths.indices.contains(source), let strength = strengths[source] else { return 0 }
        let bounded = min(max(strength, -1), 1)
        return bounded * pow(abs(bounded), Float(hops - 1)) * fractions[source]
    }
}
