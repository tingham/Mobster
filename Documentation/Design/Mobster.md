# Mobster
*Because he pushes things around*

Design requirements. Narrative background lives in the principal issue.

## Package

**mobster.model.none**
Mobster declares no document model and imports none.

**mobster.import.permitted**
Imports other than a document model are permitted where they earn their cost.

**mobster.identity.opaque**
A point identifier and a stroke identifier each cross the boundary as an opaque unsigned integer.

**mobster.identity.opaque.read**
Mobster does not dereference an identifier. An identifier is a key and nothing else.

**mobster.identity.mint.never**
Mobster does not mint an identifier.

**mobster.implementation.swift**
Work is implemented in Swift through the sub 1.0 versions. A kernel is written only where Swift cannot serve.

**mobster.transfer.value**
Data crosses the boundary as value types.

**mobster.transfer.event**
Bulk transfer occurs on membership change and on field change. Advancement carries a time and returns displaced locations with rectangles.

## Space

**guide.initialize**
A Guide receives the Frame it operates within when it is constructed, so that no workload can run before it. Initialize supplies a new Frame and resets.

**guide.frame.region**
The Frame is a region in scene space.

**guide.frame.position**
The Frame carries a position within scene space.

**guide.initialize.reset**
Initialize discards every existing token and rebuilds the membership. There is no incremental token removal.

**guide.space.scene**
Locations, targets and returned rectangles are expressed in scene coordinates.

**guide.space.normalize**
Normalization to a zero to one identity is applied only where a calculation requires it, and is reversed before storage.

## Sources

**guide.target**
A Guide names the layer it applies to. Points inside strokes on that layer are its membership.

**guide.source.layer**
A Guide may name a layer as its source. Stroke data from that layer is interpreted by Mobster into paths.

**guide.source.preset**
A Guide may name a preset as its source. The preset plots paths against the Frame the Guide operates within.

**guide.source.map.absolute**
A source Frame differing from the target Frame maps absolutely. Mobster does not fit source bounds to target bounds.

## Paths

**path.interpret**
Source locations are interpreted into paths with curvature. The interpretation is Mobster's own and does not reproduce the source representation.

**path.decimate**
Interpreted paths are decimated before they are baked.

**path.complexity.cap**
A path exceeding the complexity cap is reduced by removing entries until it conforms. It is neither truncated nor rejected. The cap is derived in the harness.

**path.vend**
Interpreted paths are vended to the consumer on demand.

**path.role**
A vended path carries what it is. A consumer can distinguish a ruler's base line from its parallels, and a spiral from the rectangles it was derived from, without relying on the order they arrive in.

## Presets

**preset.storage.static**
A preset whose paths are fixed is stored as a JSON resource.

**preset.storage.generated**
A preset whose paths are computed from parameters is a code function.

**preset.frame.mode**
A preset holds its plot mode. The mode is set when the preset is constructed and is not a parameter of the request.

**preset.frame.aspect**
A preset plotting in aspect mode plots paths consistent to the aspect ratio of the Frame. The Frame is its design rectangle, so a quantity the preset expresses relative to the Frame resolves against the Frame.

**preset.frame.bounds**
A preset plotting in bounds mode plots paths scaled to a minimum bounds encompassing the Frame, preserving its own proportions.

**preset.frame.bounds.center**
A preset scaled to a minimum bounds is centered within the Frame.

**preset.frame.mode.default**
Thirds, Columns, Rows, Ruler and Curve construct in aspect mode. Each is defined relative to the Frame and a Frame relative quantity resolves against the Frame only in that mode.

**preset.goldenRatio**
A spiral populating the standard ratio frame.

**preset.goldenRatio.proportion**
Golden Ratio preserves its own proportions. It constructs in bounds mode and does not plot in aspect mode, because a distorted spiral is not the golden ratio.

**preset.goldenRatio.quadlines**
Golden Ratio plots the nested rectangles the spiral is derived from alongside the spiral.

**preset.goldenRatio.focus**
The corner the spiral converges toward is selectable.

**preset.thirds**
Three columns and three rows conforming to the aspect ratio of the Frame.

**preset.columns**
Columnar dividers spread evenly across the Frame with a parameterized gutter.

**preset.rows**
Row lines spread evenly across the Frame with a parameterized gutter.

**preset.gutter.band**
A gutter is a band with two edges. A count of four columns with one gutter width yields six lines.

**preset.gutter.fraction**
A gutter width is a fraction of the Frame extent along the axis it divides. Its meaning does not change with plot mode.

**preset.ruler**
Two circular degrees derive two locations on the edge of the Frame.

**preset.ruler.center**
The center the degrees are cast from is specified in x and y.

**preset.ruler.degrees**
A degree of zero points along positive x within the Frame. Increasing degrees rotate toward positive y.

**preset.ruler.line**
A line crosses the Frame between the two derived locations.

**preset.ruler.pair**
A distance parameter creates a parallel line at that offset on each side of the line.

**preset.ruler.pair.cross**
A parallel line crosses the Frame. It is cast to the edge of the Frame rather than translated as a fixed length.

**preset.curve**
Identical in structure to the ruler, with a location between the start and the end controlling the tension of the interpreted spline.

## Field

**field.bake**
The field is baked from the interpreted paths in Swift on the host.

**field.bake.exterior**
A path location outside the Frame participates in the field. A query inside the Frame resolves to the true nearest path location whether that location lies inside the Frame or not.

**field.store.location**
The field stores the nearest path location per texel. It does not store a distance.

**field.store.location.exact**
The stored location is the nearest path location. It is not an approximation of one. A location bound is discontinuous in the distance error near a medial line, so an approximate bake cannot be licensed by stating a tolerance on the location.

**field.read.distance**
Distance at a location is the length from that location to the nearest path location the field holds.

**field.read.direction**
Direction at a location is the normalized vector from that location toward the nearest path location the field holds.

**field.gradient.never**
Direction is not derived from a gradient of the field.

**field.unsigned**
The field is unsigned. A guide path is open and has no interior.

**field.tiebreak.center**
Where two path locations are equidistant the field resolves toward the center of the Frame.

**field.tiebreak.stable**
Where neither candidate is nearer the center of the Frame, the field resolves to the candidate with the lesser x, and to the lesser y where x is equal. The rule is stated so that it survives a change to the order the bake sweeps in.

**field.extent**
A field's texel counts follow from the Frame and the resolution. They do not vary with whether the bake found a path.

**field.frame.degenerate**
A Frame with a zero extent on either axis bakes an empty field. It does not trap.

**field.empty**
A field holding no path location reports that it holds none. It does not vend a grayscale, because a raster of uniform maximum distance cannot be told apart from a legitimate one.

**field.vend.grayscale**
The field is vended as a grayscale rasterization on demand. The rasterization is an approximation and is not the storage format.

## Adherence

**guide.adherence.reach**
Adherence controls the reach of an inverse distance squared falloff against the field.

**guide.adherence.reach.full**
At an adherence of one every point in the Frame settles within the settle epsilon of its nearest path location. The reach achieving this follows from the Frame extent and the epsilon. A reach merely equal to the Frame extent does not achieve it, because the falloff yields a weight below one for every finite reach.

**guide.adherence.reach.least**
At the least adherence the reach collapses and no point is displaced.

**guide.adherence.reach.half**
The reach is the distance at which a point is displaced half the way to its nearest path location. A point nearer than the reach is carried most of the way, a point further is barely carried at all.

**guide.adherence.falloff**
The falloff yields a weight of one over one plus the square of distance over reach.

**guide.adherence.target**
A point's target is its own location displaced toward the nearest path location by the falloff weight of the distance between them.

**guide.adherence.short**
A point far from every path settles short of the path rather than arriving at it.

**guide.adherence.reach.full.derive**
The reach satisfying full adherence follows from the worst case distance in the Frame and the settle epsilon. Mobster vends it. It grows faster than the Frame does, so a fixed multiple of the Frame extent does not serve.

**guide.adherence.change**
Changing adherence resolves every target again from each point's current location, and ends the segment in flight as a field change does.

**guide.adherence.curve**
The mapping from the adherence dial to a reach is derived in the harness, between zero and the reach that satisfies full adherence.

## Token

**token.create**
A token is created for each point in the membership that does not already have one.

**token.reuse**
An existing token for a point is reused.

**token.identity.stroke**
A token carries the identifier of the stroke its point belongs to.

**token.identity.point**
A token carries the identifier of its point.

**token.progress**
A token stores the current location of its point.

**token.target**
A token stores the location its point will land on.

**token.origin**
A token stores the time origin of the segment in flight.

**token.planar**
A token carries no depth. A Guide does not displace a point in depth.

**token.segment**
A field change ends the segment in flight and starts a new one anchored at the current location.

**token.authority.none**
A token holds no authority over the point it references.

## Advancement

**guide.play**
A Guide advances by play, receiving a speed and a time.

**guide.play.evaluate**
Every token in the membership is evaluated at the supplied time.

**guide.play.absolute**
Evaluation at a time yields the same location whatever times were evaluated before it. Playing to a time is not an increment from the last play, and a time already played returns the picture that time produced the first time.

**token.origin.segment**
The time origin is written when a segment begins, at tokenization and at a field change. It is not written on evaluation.

**guide.play.end**
Playing to the end time settles every token in one call.

**guide.rate**
The rate at which a point travels to its target is derived in the harness.

**guide.determinism.pure**
Evaluation within a segment is a pure function of the token and the time. No wall clock and no drawn random state participate.

**guide.determinism.seed**
A seed required by the rate is derived from the point identifier.

**guide.pass.single**
A pass resolves one Guide. Two Guides on a layer are resolved by two passes, sequenced by the consumer.

**guide.rect.dirty**
Advancement returns rectangles in scene coordinates covering advanced points, individually or as unions.

## Settlement

**guide.settle.epsilon**
A point has settled when it is nearer its target than the settle epsilon. The comparison is strict, so that a point exactly one epsilon out is not already settled before the play that carries it home. The epsilon is expressed in scene units and supplied by the consumer, which is the only party that knows what a pixel is worth.

**guide.settle.notify**
A Guide notifies its listeners when every point has settled.

**guide.settle.epsilon.change**
Setting the settle epsilon observes settlement again. It does not resolve targets, because the epsilon decides only whether a point has arrived and not where it is going.

**guide.settle.notify.enter**
The notification fires on entering the settled condition, including a membership that is already settled when it is created. It fires once per settled condition and again only after a change that unsettles the membership.

**guide.settle.arrival**
A point's arrival is judged after it moves, not before. A point one epsilon from its target moves onto it and that play is the one that settles it.

**guide.settle.track.never**
A Guide does not track settled state and does not walk its membership to answer for it. It may carry what the last pass counted, since that is a record of a pass already taken rather than a state that can disagree with the points.

## Skip Takes

**guide.skiptake.source**
A stroke event on the source layer updates the field.

**guide.skiptake.target**
A stroke event on the target layer updates the membership.

**guide.skiptake.retarget**
A field change updates the target of every token.

**guide.skiptake.tokenize**
New data on the target layer is tokenized and evaluated against the field.

**guide.skiptake.remove**
Data removed from the target layer is handled by initialize. A Guide does not reconcile a membership against a removal.

**guide.skiptake.advance**
A skip take may advance the modulation step of any number of points in the membership.

## Adherence Extensions

**Not an implementation target. A 1.1 tier concept, recorded so it is not rediscovered.**

A per point property could modulate how strongly adherence acts on that point, the way a physics simulation consumes mass. Size or Coverage, either but not both, and as an option rather than as a requirement of the mechanism.

Marks made outside a range could be left unaffected entirely, so that a guide can coexist with free painting on the same layer. The range could derive from adherence, which would make one control govern both how strongly a point is drawn and how far the guide reaches to claim one. This is likely workload specific rather than an option.

Note what the second changes about the shipped behaviour. Under guide.adherence.short every point in the membership is drawn some distance, however small, because the falloff is nonzero at every finite distance. A range cutoff is the difference between a guide that weakly disturbs the whole layer and one that leaves distant work alone.

## Destructive Workload

**Not an implementation target. Recorded so it is not rediscovered.**

A Guide applying destructively yields a reduced result the consumer writes back into the live stroke, rather than filtering ahead of rasterization. The internal logic is the same as the live workload, so the consumer can achieve this result with the live workload alone. A committed point is already at its target, so the consumer routes only live strokes to avoid compounding the displacement. A reduced result is a subset of the identifiers supplied. Open: whether the destructive result differs from the settled live result at all.

## Harness

**harness.platform**
The harness is an Xcode project targeting macOS.

**harness.fixture**
The harness carries a nominally complex dataset as a fixture.

**harness.preview**
The harness presents a preview to the screen.

**harness.timing**
The harness reports performance timing.

**harness.sliders**
The harness exposes each derived magnitude as a slider.

**harness.copy**
Data structures taken from Jerome, Tempest or Muslin are hard copies. They are not linked or referenced by path to their origins.
