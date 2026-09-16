/// What a Guide refused at initialize. The bake and the mesh source each fail for their own reasons and a consumer that can only read one of them is told nothing by the other.
public enum GuideRefusal: Error, Hashable, Sendable {
    case field(FieldRefusal)
    case mesh(MeshRefusal)
}
