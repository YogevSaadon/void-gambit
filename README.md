# CosmoSpin- Bullet Heaven Game

**A component-based bullet heaven game built in Godot 4 with modular architecture and data-driven design**

## What's Built So Far

CosmoSpin demonstrates solid game architecture patterns applied to the bullet heaven genre. The project focuses on clean code organization, modular systems, and data-driven configuration.

**Current Features:**
- Four-weapon system with auto-targeting and distinct mechanics
- Component-based player architecture with movement, blinking, and weapon systems
- Dynamic stat modification system with JSON-driven item configuration
- Enemy AI with power-level scaling and modular behavior components
- Chain laser targeting system with multi-enemy reflection
- Real-time damage numbers with visual feedback
- Hangar system for weapon/item management between levels

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

## Technical Systems

### Weapon Framework
Four distinct weapon families with shared inheritance:
- **Bullet Weapons** - Fast projectiles with piercing potential
- **Laser Weapons** - Chain targeting with enemy reflection mechanics
- **Rocket Weapons** - Area damage with explosion radius scaling
- **Bio Weapons** - Damage-over-time with infection spread mechanics

```gdscript
# Type-specific damage scaling
func _damage_type_key() -> String:
    return "bullet_damage_percent"  # Each weapon scales differently
```

### Player Data System
Runtime stat calculation supporting both additive and percentage modifiers:
```gdscript
func get_stat(stat: String) -> float:
    var base = base_stats.get(stat, 0.0)
    var add = additive_mods.get(stat, 0.0)
    var pct = percent_mods.get(stat, 0.0)
    return (base + add) * (1.0 + pct)
```

### Enemy System
- **Power Level Scaling** - Stats multiply by power level for progression
- **Modular AI Components** - Movement and attack behaviors as separate nodes
- **Status Effects** - Infection system with stacking and duration
- **Dynamic Spawning** - Wave manager with level-based enemy count scaling

### Chain Laser Implementation
Multi-target beam system that:
- Maintains enemy chain arrays with validation
- Updates visual beam segments in real-time
- Handles target loss and chain extension
- Applies damage with crit chance calculation

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

## Known Technical Debt

### Performance Considerations
- Enemy targeting uses linear O(n) searches (needs spatial partitioning for 100+ enemies)
- No object pooling for bullets/explosions (creates garbage collection pressure)
- Chain laser validation runs every frame (could benefit from interval caching)

### Code Quality Items
- Inconsistent initialization patterns across systems
- Signal connection/disconnection could be more robust
- Some global node lookups lack null safety checks
- Memory management relies on Godot's automatic cleanup

## How to Run

1. Install Godot Engine 4.3+
2. Clone repository and open `project.godot`
3. Run `MainMenu.tscn` scene for full game experience

**Controls:** 
- Right-click: Move to cursor
- Left-click / F: Blink to cursor  
- Space: Hold to follow cursor
- Weapons auto-target nearest enemies

## Next Steps

**Planned Improvements:**
- Object pooling system for better performance
- Spatial partitioning for enemy targeting optimization  
- Meta-progression system for permanent upgrades
- Visual effects and screen shake for game juice
- Save/load system for run persistence

---

*A solid foundation demonstrating good architecture patterns in game development, with clear areas for performance optimization and feature expansion.*
