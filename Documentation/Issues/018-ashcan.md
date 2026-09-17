# Cut 17: Ashcan preset

## Requirements covered

preset.ashcan, preset.ashcan.sex, preset.ashcan.heads, preset.ashcan.pose, preset.ashcan.pose.pole, preset.ashcan.heads.lines

## Deliverable

A human figure plotted as construction forms against the Frame: ribcage, pelvis, limbs as tapered forms, head mass.

Parameters: sex, height in heads, a target for each hand and each foot, a pole direction per limb, and whether head break lines are drawn.

## Proportion

Height in heads is the parameter and proportion follows published canon at that height. Eight heads is heroic, seven and a half is a realistic adult, and shorter figures follow the documented child tables rather than being an adult scaled down — a child is not a small adult and a figure that reads as one is the failure this requirement exists to prevent. Look the tables up; do not derive them.

## Posing

Two bone inverse kinematics per limb, solved from the shoulder or hip to the supplied target. The closed form is the law of cosines; do not iterate.

Each limb carries a pole direction for its elbow or knee. Without it a two bone solve has a circle of valid solutions and picks one arbitrarily, which is how an elbow ends up bending the wrong way.

A target beyond the limb's reach is not an error. Extend the limb straight toward it rather than refusing or clamping the target.

## Head break lines

Horizontal half width lines to either side of the figure at each head break, optional. These are a measuring device rather than part of the figure.

## No art is needed

Bridgman, Loomis and Reilly all teach the figure as boxes, wedges and tapered cylinders because that is what is derivable. Plot the construction. Do not attempt an appealing mannequin silhouette; that would be drawing and it is not what this is for.

## Constraints

- Swift only. One type per file, filename matching.
- It constructs in aspect mode as the other Frame relative presets do.
- Deterministic: the same Frame and parameters yield an identical sequence every time.
- Posing is the consumer's interaction. This preset receives settled targets and plots; it does not manipulate anything.

## Acceptance

`swift build` and `swift test` green. Registered in `PresetDeterminismTests.plotters` and in the tolerance sweep. Wired into the harness with controls for sex, heads, the four targets, the pole directions and the head line toggle. A two bone solve is asserted against a hand derived triangle. A target out of reach extends the limb rather than failing. Head break lines sit at the fractions the height implies, asserted literally. A test fails when the proportion table changes.
