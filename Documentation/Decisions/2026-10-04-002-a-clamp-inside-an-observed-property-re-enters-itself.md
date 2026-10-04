# A clamp inside an observed property reenters itself

Date: 2026-10-04

## Context

The harness opened at a derived settle epsilon for the first time in this cycle, and the epsilon it opens at carries a floor: the slider may not travel below what the budget affords. The floor was held by clamping inside the property's own `didSet`, on the strength of the language rule that a self assignment inside an observer does not reenter it.

The principal selected Golden Ratio and the harness died. The dispatch brief carried a hypothesis for why, which measurement disproved, and the fix required restructuring the property rather than correcting an expression. Nobody in the cycle anticipated the mechanism.

## The hypothesis that was wrong

The proposed cause was arithmetic creep. `FieldResolution.epsilon(count:frame:)` returns its value `.nextUp`, and the affordability bisection in `FieldBake` round trips through `Float` in `fits()`, so a floor derived while the epsilon already stood on the floor might come back one place higher each pass. `standing < floor` would stay true forever with the floor climbing, which exhausts a stack rather than hanging, and Golden Ratio at two hundred and eighty eight form segments was plausibly where the arithmetic landed on that edge when a sparser preset did not.

It is a good hypothesis and it is false. The floor was measured over twelve passes of the sequence the harness actually walks — derive the floor, stand the epsilon on it, bake there, derive again — for Golden Ratio at the opening budget of two million:

    pass 1  standing 0.6000907  floor 4.159452  bits 1082464827  carried true   bake 102x68
    pass 2  standing 4.159452   floor 4.159452  bits 1082464827  carried false  bake 102x68
    pass 3 through 12 are identical to pass 2, bit pattern 1082464827 on every one

The derivation is a pure function of the source, the Frame and the budget. A retune changes none of the three, so the carry fires once, the next pass finds the floor already met, and the afford and retune cycle is bounded at depth two exactly as it was reported to be. The recursion was never there, and no amount of staring at the bisection would have found it.

## Diagnosis

Swift suppresses a self assignment inside a property's own observer. That rule is about a stored property, and under the `@Observable` macro the property is not one. The macro rewrites a stored declaration into a computed property whose accessors go through `withMutation` and `ObservationRegistrar`, over separate storage — `settleEpsilon` over `_settleEpsilon` — and the observers travel with the storage rather than with the name. So an assignment to `settleEpsilon` from inside `_settleEpsilon`'s `didSet` is a setter call on a different symbol. The suppression never engages, and the observer runs again.

The re-entry is unconditional on the value. The clamp converges on its first pass and the recursion continues anyway, which is why a convergence argument about the floor — the argument that was made, accepted at reconciliation, and is correct on its own terms — bounds nothing. Any write to the property from inside its own observer recurses until the stack is gone, whatever it writes.

Demonstrated in a standalone binary with the same property body under both regimes:

    @Observable final class Observed {
        var value: Float = 1 {
            didSet {
                depth += 1
                print("observed: depth \(depth), value \(value)")
                value = max(value, 4)
            }
        }
        var depth = 0
    }

    final class Plain {
        var value: Float = 1 {
            didSet {
                depth += 1
                print("plain: depth \(depth), value \(value)")
                value = max(value, 4)
            }
        }
        var depth = 0
    }

Setting `value = 2` on each:

    observed: depth 1, value 2.0
    observed: depth 2, value 4.0
    observed: depth 3, value 4.0
    observed: depth 4, value 4.0   ... climbing, the value unchanged from depth 2 onward
    plain:    depth 1, value 2.0   ... and stops

## The crash signature

Stack exhaustion presents as `EXC_BAD_ACCESS` with code 2 and `SIGSEGV`, reported against `swift::runtime::AccessSet::insert`, and the report says "Could not determine thread index for stack guard region". It reads as a bad pointer and it is not one: the faulting address is the stack guard page.

What identifies it is the shape above that frame. The repeating unit is three frames — the computed setter, the underscored storage setter, the storage's `didSet` — with `ObservationRegistrar.withMutation` inside each turn, repeating until the guard page. Whatever called the property appears once, at the bottom, below the repetition: here `afford()` and `reload()` and `replot()`, each exactly once. A single appearance of the caller under an unbounded repetition of the setter triple is the whole diagnosis, and it is visible without a debugger in the crash report the principal forwarded.

## Decisions

### The clamp moves out of the observer

A property that must constrain what is written to it is declared computed over private storage, with no observer anywhere on the path, and the constraint is applied in the setter on the way in. Nothing writes the observed name from inside anything the observed name invokes.

A reentrancy flag was considered and rejected. It would have left the recursion in place and suppressed it, which conceals the mechanism from the next reader and fails the moment a second write arrives for a different reason.

### This class of defect is caught by hand in this repository, or not at all

The harness has no test target by the principal's arrangement: "we don't test the harness - thats what OneBrush is for; unit tests on the package logic... that's just good housekeeping." The package suite passed in full while the crash was live — three hundred and thirty nine tests at the commit that carried it, three hundred and forty one as the reconciliation counted them on its own base — because not one line of package code was involved.

So a defect in the harness's own state handling is found by running the harness and by nothing else. The verification for this fix was to drive a real `HarnessModel` in process through every preset in the picker, both ends of the budget on a dense preset and a sparse one, a swap in each direction, and an epsilon written below the floor. Twenty three steps, every one baking. That it had to be driven programmatically rather than clicked is an artifact of who was holding the mouse, not a weakening of the method.

## Found in the same pass

`epsilonRange` widened its top whenever twice the floor exceeded the by eye ceiling of twenty, rather than only where the floor had passed that ceiling, which is what the decision behind it said. At the minimum budget Golden Ratio offered a span of 18.446266 to 36.892532 where the ceiling should have stood at twenty. It is a separate defect with a separate cause, recorded here only because the run that found the first found it too, and because a derived bound that moves a bound set by eye is the kind of thing nobody notices until a screenshot looks wrong.

## Open, and not decided here

- Whether the other observed properties on `HarnessModel` carry a write to themselves from anything their observers reach. None was found by reading, and none was proven absent.
- Whether the harness's remaining `didSet` observers are better expressed the same way. The crash does not argue for it; only a write to self does, and the others do not make one.
- Whether this record belongs anywhere the principal's other projects can read it. The fact is about `@Observable` rather than about Mobster, and those projects use it heavily.

Recorded by Doozer/Renderer.
