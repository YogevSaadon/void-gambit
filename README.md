<!-- Hero GIFs -->
<p align="center">
  <img src="assets/media/gif1.gif" width="49%" alt="Core gameplay">
  <img src="assets/media/gif3.gif" width="49%" alt="Boss/wave highlight">
</p>

# Void Gambit — 2D Bullet-Heaven (Godot 4)

**TL;DR:** Real-time bullet-heaven focused on clean architecture and practical performance engineering: math-driven targeting (no physics), staggered updates, cached queries, and zone-based AI with hysteresis.

## Features
- Four weapon types with distinct mechanics and auto-targeting
- Companion/ally system with formation flying and autonomous combat
- Multi-state enemies (chase / maneuver / retreat)
- Data-driven items & stats (JSON) with runtime validation
- Visual damage feedback, chain-laser targeting, and effect cleanup

## AI / Movement & Targeting (no physics)
- **Custom Area2D + vector math** replaces heavy collision queries
- **Range-keeping** with CLOSE/MEDIUM/FAR zones and **hysteresis** to avoid oscillation
- **Staggered decision timers** (per-enemy) to prevent same-frame spikes
- **Cached distances** computed on intervals and reused each frame
- **Individual variance** (± speed & timers) for natural swarm behavior
- Partial **C++/GDExtension** path for targeting where hot loops matter

## Architecture
- **Component composition**: e.g., `BlinkSystem`, `WeaponSystem`, `PlayerMovement`
- **Signal-driven communication** between systems (loose coupling)
- **Manual manager access** (no Autoload singletons)
- **Data-driven configuration**: JSON items/stats; new items appear without code changes
- Clean separation of responsibilities; minimal per-frame allocations

## Performance Notes (honest, no hard numbers yet)
- Runs smoothly with large enemy counts on a mid-range PC
- Techniques used:
  - Interval-based expensive checks; cached results (avoid repeated sqrt)
  - Staggered updates across entities to spread work per frame
  - Zone-based AI + hysteresis for stable range control
  - Reduced allocations in hot paths; explicit cleanup via node lifecycle
- **Benchmarks TBD** — profiling harness in progress (Godot Profiler + fixed spawn counts)

## Example Snippets
```gdscript
# GDScript — stat calculation example
func get_stat(stat: String) -> float:
    var base = base_stats.get(stat, 0.0)
    var add  = additive_mods.get(stat, 0.0)
    var pct  = percent_mods.get(stat, 0.0)
    return (base + add) * (1.0 + pct)
```

```json
{
  "id": "reinforced_plating",
  "name": "Reinforced Plating",
  "description": "+25 Max HP",
  "rarity": "common",
  "price": 1,
  "category": "stat",
  "stat_modifiers": { "max_hp": 25 }
}
```

## How to Run Locally
- **Godot 4.3+**
- Open `project.godot`
- Run `MainMenu.tscn`

## Controls
- **Right-click**: Move to cursor
- **Left-click / F**: Blink
- **Space (hold)**: Follow cursor
- **Weapons auto-target**

## Tech Highlights
- Real-time systems, profiling, data-driven design
- GDScript + selective C++/GDExtension
- Component architecture with signal-based communication
- Math-driven collision (no physics) for performance scaling
