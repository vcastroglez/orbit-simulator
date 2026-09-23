# OrbitSimulator

OrbitSimulator is a personal, unfinished Godot experiment exploring how orbital motion can be visualized through spacetime-curvature-inspired models rather than Godot's built-in gravity.

The project contains two stages of the experiment:

- **`main`**: the current Schwarzschild-inspired geodesic approximation.
- **`original-curvature-model`**: the original conceptual prototype, preserved for comparison.

> This is an educational and visual experiment, not a scientifically validated general-relativity solver. Constants are intentionally scaled so relativistic-looking effects are visible in a 2D game-sized simulation. Put less formally, the speed of light has been nerfed so the interesting bits fit on screen.

## Current model

The `main` branch calculates acceleration from a simplified Schwarzschild-inspired expression:

```text
a = -(G·M / (r² · (1 - rs/r))) · (1 + v²/c²) · r̂
```

The simulation uses game-unit values for `G` and `c`. In particular, the effective speed of light is reduced so that effects such as orbital precession and event-horizon capture are visible at practical pixel distances.

Massive bodies:

- influence one another through the custom geodesic approximation;
- bypass Godot's built-in gravity and damping;
- merge at close range while conserving linear momentum;
- accumulate mass and change appearance;
- become an anchored black-hole representation at three solar masses.

The black-hole threshold, anchoring behavior, merge radius, and scaled constants are simulation design choices rather than claims of physical accuracy.

## Original curvature model

The `original-curvature-model` branch preserves the first version of the idea. It calculates a curvature percentage from the Schwarzschild time-dilation factor:

```text
curvature = (1 - sqrt(1 - rs/r)) × 100
```

That percentage was then mapped to a normalized attraction direction using an arbitrary multiplier so the motion would be visible. This was a conceptual prototype and is not a physically rigorous force calculation. It was superseded by the geodesic approximation on `main`.

## Controls

| Input | Action |
|---|---|
| Right-click | Spawn an Earth-mass body |
| `E` | Spawn a Sun-mass body |
| Mouse wheel | Zoom in or out |
| Left-click and drag | Pan the camera |

## Running the project

1. Install **Godot 4.6**.
2. Clone the repository.
3. Open `project.godot` in Godot.
4. Run the project with **F5**.

The main scene is `universe/universe.tscn`.

## Structure

| Path | Purpose |
|---|---|
| `universe/physicist/calculations.gd` | Physical constants, Schwarzschild radius, curvature visualization, and geodesic approximation |
| `universe/massive_object/massive_object.gd` | Per-body integration, merging, momentum conservation, and appearance changes |
| `universe/universe.gd` | Camera controls and body spawning |
| `universe/universe.tscn` | Main simulation scene |

## Limitations

- The simulation is two-dimensional.
- It does not numerically solve the full Einstein field equations or a complete four-dimensional metric.
- Relativistic effects are deliberately exaggerated through game-scaled constants.
- Integration is frame-step based and is not intended for scientific computation.
- Collision merging and black-hole behavior include gameplay-oriented rules.
- There is currently no automated test suite.

## Status

This is a personal experimental project and remains unfinished. It is published as a record of the exploration and the evolution from the original curvature-percentage prototype to the current Schwarzschild-inspired geodesic model.
