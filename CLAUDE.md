# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Project

This is a **Godot 4.6** project. Open it in the Godot editor and press F5 (or the Play button) to run. The main scene is `universe/universe.tscn`.

There is no CLI build or test runner — all development happens through the Godot editor.

## Controls

| Input | Action |
|-------|--------|
| Right-click | Spawn Earth-mass body at cursor |
| `E` | Spawn Sun-mass body at cursor |
| Scroll wheel | Zoom in/out |
| Left-click drag | Pan camera |

## Architecture

The project has three scripts:

### `universe/physicist/calculations.gd` — Autoloaded singleton (`Calculations`)
Registered as an autoload in `project.godot`. Provides physical constants (`G`, `C`, `earth_mass`, `sun_mass`) and two key functions:
- `spacetime_curvature_percent(distance_m, mass_kg)` — returns 0–100% curvature using the Schwarzschild metric (`sqrt(1 - rs/r)`)
- `schwarzschild_radius(mass)` — returns the event horizon radius

### `universe/massive_object/massive_object.gd` — `MassiveObject` (RigidBody2D)
Each body iterates over all sibling `MassiveObject` nodes every physics frame, computes gravitational attraction via `spacetime_curvature_percent`, and applies a scaled force. Key design points:
- **Scale factor**: `1.0e-6` — 1 pixel equals 1,000 km. Pixel distances are divided by `scale_factor` to get meters before feeding into physics formulas.
- **`force_multiplier`** (`1.25e27`): raw curvature values are tiny; this constant amplifies them to produce visible in-game motion. It has no physical basis.
- Bodies with `body_mass <= earth_mass` get a random initial velocity; bodies with `body_mass >= 25000 * earth_mass` render with a sun texture.
- Godot gravity is disabled (`gravity_scale = 0.0`); damping is zeroed so only the custom force accumulation governs motion.

### `universe/universe.gd` — Universe (Node2D)
Owns the `Camera2D` and handles input: spawning bodies, panning, and smooth zoom interpolation clamped to [0.1, 2.0].

## Key Files

| Path | Purpose |
|------|---------|
| `project.godot` | Godot project config; defines autoload, input map, GL Compatibility renderer |
| `universe/universe.tscn` | Main scene; contains the pre-placed Sun and several planet bodies |
| `universe/massive_object/massive_object.tscn` | Reusable body scene (RigidBody2D + Sprite2D + VelocityVector arrow) |
