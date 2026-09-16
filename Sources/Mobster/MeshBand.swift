/// A ring of locations stitched to another of the same count, which is what every solid of a construction is built out of. The winding is decided here rather than in each form, and a facet with no area is dropped so that a ring closing onto a pole costs a fan rather than a band.
struct MeshBand {
    let first: [SIMD3<Float>]
    let second: [SIMD3<Float>]
    let identity: MeshIdentity

    /// The band closed around, the last facet joining the last location of each ring back to the first. The place a location is carried to is the caller's, a construction having parts the view turns and parts it does not.
    func triangles(_ place: (SIMD3<Float>) -> SIMD3<Float>) -> [MeshTriangle] {
        guard first.count == second.count, first.count > 2 else { return [] }

        return first.indices.flatMap { index -> [MeshTriangle] in
            let next = (index + 1) % first.count
            let near = place(first[index])
            let along = place(first[next])
            let across = place(second[next])
            let back = place(second[index])

            return [triangle(near, along, across), triangle(near, across, back)].compactMap { $0 }
        }
    }

    private func triangle(_ first: SIMD3<Float>, _ second: SIMD3<Float>, _ third: SIMD3<Float>) -> MeshTriangle? {
        guard first != second, second != third, first != third else { return nil }

        return MeshTriangle(first: first, second: second, third: third, identity: identity)
    }
}
