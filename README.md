# Void Gambit - Space Shooter

<div align="center">
  <img src="assets/media/gif1.gif" width="80%" />
  <br/>
  <img src="assets/media/gif2.gif" width="80%" />
  <br/>
  <img src="assets/media/gif3.gif" width="80%" />
</div>

**A performance-optimized space shooter demonstrating advanced software engineering practices and real-time system programming**

## What's Built

Void Gambit showcases solid software engineering applied to real-time interactive systems. The project emphasizes clean architecture, performance optimization, and complex system interactions.

**Core Systems:**
- Four-weapon system with intelligent auto-targeting and distinct mechanics
- AI weapon system that spawns ally ships with autonomous behavior
- Component-based player architecture with modular movement, blinking, and weapon systems
- Dynamic stat modification system with JSON-driven configuration
- Multi-state enemy behavior system with performance-optimized movement patterns
- Companion ship system with formation flying and autonomous combat behavior
- Chain laser targeting with dynamic rebuilding and spatial optimization
- Power budget spawning system with variety algorithms and anti-clustering
- Real-time damage feedback and visual effects management

## Architecture Overview

### Core Design Patterns
- **Component Composition** - Player built from specialized subsystems (BlinkSystem, WeaponSystem, PlayerMovement)
- **Signal-Driven Communication** - Loose coupling between game systems via events
- **Service Locator Pattern** - Global managers accessible via scene tree lookup
- **Data-Driven Configuration** - JSON-based items and stats for runtime flexibility

### System Organization
- **No Autoload Singletons** - All managers created and accessed manually through scene tree
- **Modular Components** - Each system handles specific responsibilities with clear interfaces
- **Event-Based Updates** - Systems communicate through signals rather than direct coupling

## Technical Implementation

### AI Weapon & Ally Ship System
**Solution:** Weapon-spawned ally ships with autonomous combat behavior
- **Dynamic spawning** creates ally ships through weapon system
- **Formation flying** maintains intelligent positioning relative to player
- **Multi-state behavior** switches between patrol, combat, and return modes
- **Autonomous targeting** using optimized collision detection systems
- **Performance optimization** through staggered calculations and object pooling considerations

### Dynamic Spawning & Probability Systems
**Solution:** Power budget allocation with mathematical progression
- **Bin-packing algorithm** distributes enemy power with variety balancing
- **Probability distribution** using weighted selection and diminishing returns formulas
- **Anti-frustration systems** with pity counters and escalating guarantees
- **25-level progression** with sigmoid curves and psychological breakpoints

### Multi-State Enemy Behaviors
**Solution:** Individual behavior variation with optimized state transitions
- **Zone-based positioning** with hysteresis buffers prevents oscillation
- **Staggered calculations** spread expensive operations across frames
- **Individual speed variation** (±25%) creates natural swarm behavior
- **Behavioral states** dynamically switch between chase, maneuver, retreat, and strafe

### Chain Laser & Targeting Systems
**Solution:** Spatial optimization with automatic chain reconstruction
- **Spatial query optimization** limits targeting complexity for performance scaling
- **Dynamic chain rebuilding** maintains targeting integrity when enemies are eliminated
- **Mathematical targeting** implements precise angle and distance calculations
- **Visual management** updates beam segments in real-time with automatic cleanup

### Runtime Stat System
Performance-optimized stat calculation supporting complex modifier stacking:
```gdscript
func get_stat(stat: String) -> float:
    var base = base_stats.get(stat, 0.0)
    var add = additive_mods.get(stat, 0.0)
    var pct = percent_mods.get(stat, 0.0)
    return (base + add) * (1.0 + pct)
```

## Current Game Flow

1. **Main Menu** - Initialize core managers and start new run
2. **Level Play** - Wave-based enemy spawning with auto-targeting weapons
3. **Hangar** - Purchase items and manage loadout between levels
4. **Progression** - Level advancement with increasing difficulty

## JSON Data Configuration

### Item System
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

### Behavior Effects
Items can spawn custom behavior nodes:
```json
{
  "id": "warp_detonator",
  "category": "behavior", 
  "behavior_scene": "res://scripts/effects/BlinkExplosionEffect.gd"
}
```

## Technical Metrics

- **Target Performance:** 60fps with 50+ concurrent enemies
- **Architecture:** Component-based with manual dependency management  
- **Weapon Capacity:** 6 simultaneous auto-targeting weapon slots
- **Data Format:** JSON configuration with runtime validation

## Performance Engineering

### Real-Time Optimization Techniques
**Solutions Implemented:**
- **Staggered calculations** spread expensive operations (distance checks, targeting) across multiple frames
- **Built-in collision optimization** leverages Godot's C++ collision detection for efficient targeting
- **Cached distance calculations** store expensive square root operations and reuse results
- **Individual update intervals** give each enemy slightly different timing to prevent simultaneous expensive operations
- **Object pooling considerations** designed into architecture for future scalability

### Memory Management
- **Automatic cleanup** leverages Godot's node system for proper resource deallocation
- **Signal-based communication** prevents circular references and memory leaks
- **Modular component design** allows systems to be independently loaded/unloaded

### Scalability Considerations
- **Component architecture** supports easy addition of new enemy types and behaviors
- **JSON configuration** allows runtime adjustment of game balance without code changes
- **Modular weapon system** enables rapid prototyping of new weapon mechanics

## How to Run

1. Install Godot Engine 4.3+
2. Clone repository and open `project.godot`
3. Run `MainMenu.tscn` scene for full game experience

**Controls:** 
- Right-click: Move to cursor
- Left-click / F: Blink to cursor  
- Space: Hold to follow cursor
- Weapons auto-target nearest enemies

## Technical Skills Demonstrated

**Software Engineering:**
- **Object-oriented design** with component-based architecture and clear separation of concerns
- **Performance optimization** including staggered calculations, caching, and spatial query optimization
- **Real-time systems programming** with frame-rate awareness and memory management
- **Data-driven design** using JSON configuration for maintainable and flexible systems

**Problem Solving:**
- **Complex system interactions** between companion ships, enemy behaviors, and weapon targeting
- **Performance bottleneck resolution** through algorithmic optimization and efficient data structures
- **State management** for multi-state behaviors and dynamic system coordination
- **Mathematical programming** for targeting, movement patterns, and spatial calculations

**Code Quality:**
- **Modular architecture** enabling independent testing and easy feature addition
- **Clean interfaces** between systems using signal-based communication
- **Configuration management** separating game logic from balance data
- **Maintainable codebase** with consistent patterns and clear documentation

---

*A complete interactive system demonstrating software engineering principles, performance optimization, and complex problem-solving skills applicable to any real-time software development role.*
