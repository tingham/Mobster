# Mobster
*Because he pushes things around*

Design requirements. Narrative background lives in the principal issue.

## Package

**mobster.frame.between**
Mobster evaluates between two frames. Carrying positions across successive sets of targets is the consuming application's work, because that is what an animation program is for and this is not one.


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
The expensive work happens once, at initialize, where the field is baked. Evaluation carries content and a time and returns content.

## Space

**guide.initialize**
A Guide receives the Frame it operates within when it is constructed, so that no workload can run before it. Initialize supplies a new Frame and resets.

**guide.frame.region**
The Frame is a region in scene space.

**guide.frame.position**
The Frame carries a position within scene space.

**guide.initialize.again**
Initializing again replaces the source, the Frame, the adhesion and the duration, and rebakes. A Guide retains nothing about content between evaluations, so there is nothing else to discard.

**guide.space.scene**
Locations, targets and returned rectangles are expressed in scene coordinates.

**guide.space.normalize**
Normalization to a zero to one identity is applied only where a calculation requires it, and is reversed before storage.

## Sources

**guide.target**
A Guide is given content to evaluate rather than a layer to own. What the consumer chooses to send, whether the stroke in progress or the whole layer, is the consumer's decision and changes nothing here.

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

**path.decimate.tolerance**
A path is decimated until its deviation from the supplied geometry reaches one texel. Detail the field cannot resolve is not carried.

**path.complexity.cap**
A path whose supplied vertex count exceeds its surviving count by more than the waste factor is rejected. The rejection reports both counts, because a consumer cannot compute the limit without knowing the field resolution.

**path.smooth.never**
Mobster does not smooth supplied geometry. The consumer has already interpreted the stroke and smoothing again discards a decision made with more context.

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
Three columns and three rows conforming to the aspect ratio of the Frame. It is a grid with a zero gutter and is kept separate regardless, because an editorial illustrator expects to find thirds by name.

**preset.columns**
Columnar dividers spread evenly across the Frame with a parameterized gutter.

**preset.rows**
Row lines spread evenly across the Frame with a parameterized gutter.

**preset.grid**
Columnar dividers and row lines together across the Frame, one count and one gutter serving both axes.

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

**field.resolution.derive**
The field resolution follows from the Frame and the settle epsilon. It is not supplied. A read snaps to the containing texel, so a texel larger than the epsilon carries more error than the tolerance the points are settling within.

**field.resolution.refuse**
A derived resolution whose bake exceeds what the package will spend is refused, reporting the epsilon asked for and the epsilon that would be affordable. The consumer chooses again rather than discovering the cost.

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

## Types

**vert**
A location, carrying an optional identifier and optional attributes. The identifier is the consumer's and is returned untouched. A consumer sending a guide needs no identifier and no attributes.

**vert.mass**
An optional weight. A vert with more mass moves less per tick.

**vert.drag**
An optional leniency across its travel, running from minus one to one. A drag of one is the plain travel. A drag of zero holds the vert back for the whole run. A drag of minus one carries it away from its target before it returns. The scale runs downward because no family linear in drag both holds back above and repels below; whichever end repels, the other runs fast.

**vert.physics**
The attributes are not only a correctness mechanism. A non destructive guide evaluating a whole layer with coupling and mass in play produces motion worth showing, which is its own reason to have them.

**vert.coupling**
An optional signed measure of how much of this vert's motion its peers take. Propagation through neighbours supplies the falloff along the line, so how far it reaches is not a separate attribute. A negative coupling opposes rather than follows.

**vert.attributes.optional**
An absent attribute is not a defaulted one. A consumer that supplies none gets motion that disregards peer state entirely.

**vert.coupling.zero**
Coupling is the exception. A coupling of zero emits no offset and an absent coupling emits none either, so the two cannot be told apart through evaluation and no test should pretend otherwise. Mass and drag both carry a distinction; this does not.

**line**
An ordered sequence of verts carrying an optional identifier. It holds no behaviour of its own; what happens to a line is what happens to its verts.

## Evaluation

**guide.initialize**
A Guide is initialized with its source, which is guide lines or a preset, the Frame it operates within, an adhesion, and a duration. The bake happens here and once.

**guide.adhesion**
Adhesion is a control between zero and one. It maps onto the reach the falloff uses, and the consumer never sees a reach.

**guide.duration**
The duration is the time at which every vert has arrived. It is supplied at initialize.

**guide.evaluate**
A Guide evaluates content, which is lines the consumer holds, at a time. It returns those lines with their verts displaced. Nothing is retained between calls.

**guide.evaluate.anchor**
The verts supplied are the anchors the displacement is measured from. A consumer holding undisplaced content and evaluating it each frame receives a stable result; a consumer feeding a result back in has declared a new anchor and asked for a further displacement.

**guide.evaluate.time**
A time yields the same result whatever times were evaluated before it. Evaluation is not an increment from a previous call.

**guide.evaluate.settled**
At the duration every vert has arrived, so a consumer wanting the settled result asks for the duration and does not iterate toward it.

**guide.field.vend**
A Guide vends a rasterization of its field on demand. The field itself is not exposed.

**guide.lines.vend**
A Guide vends the lines interpreted from its source on demand.

**guide.pass.single**
An evaluation resolves one Guide. Two Guides on a layer are two evaluations, sequenced by the consumer.

**guide.determinism.pure**
An evaluation is a pure function of the content, the Guide and the time. No wall clock and no drawn random state participate.

**guide.determinism.seed**
A seed required by a vert attribute is derived from the vert identifier.

**guide.settle.epsilon**
A vert has arrived when it is nearer its target than the settle epsilon. The epsilon is expressed in scene units and supplied by the consumer, which is the only party that knows what a pixel is worth. It sets the field resolution and the reach that full adhesion requires; it is not a control the consumer tunes for feel.

## Body

**Outcomes, not yet a parameterization. The control surface follows at implementation, with the principal.**

A vert carries three optional attributes the consumer contributes during reduction. A consumer sending a guide needs none of them; a consumer sending target content may send all of them.

- A weight. It moves less per tick.
- A counter influence. It appears stochastic across a canvas. It is derived from the vert identifier rather than drawn, or determinism is lost.
- A coupling. It says how much of this vert's motion its peers take, signed, so that peers may oppose rather than follow.

Coupling is a vert property rather than a line property. Propagation through neighbours gives the falloff along the line for free, so how far coupling reaches is not a separate parameter. A line stiff at one end and loose at the other is expressible, and a uniform line is the case where every vert carries the same value. No rule is needed for which vert's target wins on a stiff line, because the motion emerges from propagation rather than being arbitrated.

The outcomes that fall out, across the range: verts moving independently; a vert dragging its peers along weakly or strongly; a vert dragging near peers more than far ones; a vert pushing its peers away from their own targets; and a whole line moving as one body.

A line carries an identity and nothing else.

## Adherence Extensions

**Not an implementation target. A 1.1 tier concept, recorded so it is not rediscovered.**

A per point property could modulate how strongly adherence acts on that point, the way a physics simulation consumes mass. Size or Coverage, either but not both, and as an option rather than as a requirement of the mechanism.

A distance weight could be selected from a number of falloff presets and applied after the fact, because the user said so, rather than following from the field. This is not a cutoff. It is the user choosing the character of the distance response, and one of those characters happens to leave distant work alone. This is likely workload specific rather than an option.

The workload it serves is a cycle: enable the guide, paint a stroke, disable the guide, transform the guide, enable it again, paint another stroke, disable it. Marks therefore accumulate on one layer having been painted under different guide states, and the selected falloff governs how much of the earlier work responds when the guide moves.

Note what this asks of the shipped behaviour. Under guide.adherence.short every vert supplied is drawn some distance, however small, because the falloff is nonzero at every finite distance. A transform of the guide is a new initialize, so the next evaluation resolves every supplied vert against the new field. The cycle above therefore draws every previously painted mark toward each new guide position, and the selected falloff is what makes that cycle usable rather than destructive.

## Destructive Workload

**Not an implementation target. Recorded so it is not rediscovered.**

A Guide applying destructively yields a reduced result the consumer writes back into the live stroke, rather than filtering ahead of rasterization. The internal logic is the same as the live workload, so the consumer can reach this result through the live workload alone.

It is not merely a convenience. A guide used as an ITERATION TOOL rather than as a one time effect on a layer's content requires it: unless each session's result is persisted, the next cycle resolves from the original locations and the earlier session's work is undone rather than built upon. Persisting is what makes the cycle accumulate. The selected falloff then governs how much of the already persisted work the next cycle disturbs. A reduced result is a subset of the identifiers supplied.

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
