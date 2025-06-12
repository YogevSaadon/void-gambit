# Space Haven - Bullet Heaven Game

**Advanced component-based architecture and performance-optimized systems built in Godot 4**

## Executive Summary

Space Haven demonstrates enterprise-level software architecture patterns applied to game development. Features manual dependency injection, signal-driven loose coupling, and modular component systems designed for scalability and maintainability.

**Key Technical Achievements:**
- Component-based player architecture with zero autoload dependencies
- Multi-weapon auto-firing system supporting 100+ concurrent entities
- Real-time stat modification system with JSON-driven configuration
- Performance-optimized chain targeting with dynamic enemy management
- Modular enemy AI framework with power-level scaling

## Architecture Overview

### Core Design Patterns
- **Manual Dependency Injection** - Zero autoload singletons, explicit system initialization
- **Component Composition** - Player system built from specialized subsystems (BlinkSystem, WeaponSystem, PlayerMovement)
- **Signal-Driven Architecture** - Loose coupling between game systems via event-based communication
- **Data-Driven Configuration** - JSON-based item and stat systems for runtime flexibility

### Performance Engineering
- **Object Lifecycle Management** - Custom damage number pooling and cleanup systems
- **Spatial Query Optimization** - Efficient enemy targeting for chain weapons
- **Memory-Conscious Design** - Component cleanup and signal disconnection patterns
- **Scalable Entity Systems** - Architecture supports 100+ concurrent game entities

## Technical Systems

### Advanced Weapon Framework
Four-family weapon system with shared inheritance and type-specific optimizations:
- **Chain Laser System** - Multi-target reflection with performance-optimized enemy queries
- **Area Damage System** - Configurable explosion radius with collision detection
- **Projectile Management** - Bullet physics with piercing and collision optimization
- **Status Effect Engine** - Damage-over-time with infection spread mechanics

### Dynamic Stat System
Runtime stat modification supporting additive and percentage-based changes:
```gdscript
// Real-time stat recalculation
func get_stat(stat: String) -> float:
    var base = base_stats.get(stat, 0.0)
    var add = additive_mods.get(stat, 0.0)
    var pct = percent_mods.get(stat, 0.0)
    return (base + add) * (1.0 + pct)
```

### Component Communication System
- **Event-driven architecture** with typed signal parameters
- **Behavior effect spawning** via PassiveEffectManager
- **Modular AI components** for enemy behavior composition

## Engineering Challenges Solved

### Performance Optimization
- **Chain targeting efficiency** - Reduced O(n) enemy queries from per-frame to cached intervals
- **Collision system debugging** - Resolved complex layer/mask interaction issues
- **Memory leak prevention** - Fixed floating UI element lifecycle management

### Architecture Evolution
- **System connectivity** - Built robust GameManager without global state dependencies
- **Input buffering** - Implemented smooth movement with hold-to-move mechanics
- **Data persistence** - Designed flexible item save system with type safety

### Combat System Engineering
- **Attack speed scaling** - Separated weapon-specific timing from global modifiers
- **Explosion detection** - Resolved area damage collision detection edge cases
- **Movement physics** - Balanced responsive controls with smooth acceleration

## Performance Metrics

- **Target Scale:** 100+ concurrent enemies with 6 simultaneous weapon systems
- **Architecture:** Zero singleton dependencies, 3-layer component hierarchy
- **Memory Management:** Custom pooling for high-frequency objects
- **Optimization:** Frame-rate conscious design with spatial query caching

## Technical Stack

- **Engine:** Godot 4.3 with GDScript
- **Architecture:** Component-based design, manual dependency injection
- **Data:** JSON configuration with runtime validation
- **Performance:** Signal-based communication, object pooling
- **Testing:** Component isolation for modular debugging

## How to Run

1. Install Godot Engine 4.3+
2. Clone repository and open `project.godot`
3. Run main scene for immediate gameplay

**Controls:** Right-click (move), Left-click (blink), weapons auto-target

## System Requirements

- **Development:** Godot 4.3+, cross-platform compatibility
- **Runtime:** Optimized for 60fps with 100+ active entities
- **Architecture:** Modular design supports easy feature extension

---

*Demonstrates production-ready architecture patterns and performance-conscious engineering in game development context.*
