# Space Haven - Bullet Heaven Game (Work in Progress)

A modular bullet-heaven/auto-shooter built in Godot 4, focusing on clean architecture and scalable systems.

*Started: April 2025 | Current Status: Core systems functional, content development ongoing*

## Overview

Space Haven is a bullet-heaven game inspired by Vampire Survivors, built with an emphasis on software engineering principles rather than rapid prototyping. The project prioritizes maintainable code architecture, component-based design, and performance-conscious development.

**Note:** This is an active learning project. The core engine systems are functional and demonstrate various programming concepts, but content (enemies, weapons, items) is still being developed.

## Technical Architecture

### Component-Based Design
- **Player system** composed of modular subsystems: BlinkSystem, WeaponSystem, PlayerMovement
- **Manual dependency injection** - No autoload singletons, explicit system initialization
- **Signal-driven communication** - Loose coupling between game systems

### Data-Driven Systems
- **JSON-based item database** with runtime loading and validation
- **Stat modifier system** supporting additive and percentage-based changes
- **Configurable weapon families** with inheritance-based type system

## Current Implementation Status

### Completed Systems:
- Multi-weapon auto-firing system (6 slots, different weapon families)
- Player movement with smooth acceleration/deceleration and input buffering
- Teleport/blink system with behavior effect triggers
- Dynamic stat system with item-based modifications
- Component-based enemy architecture with power scaling
- Wave spawning and level progression
- Store/hangar system with item purchasing and reroll mechanics
- Damage-over-time effects with infection spreading
- Critical hit system with visual feedback
- Floating damage numbers with lifecycle management

### In Development:
- Enemy variety and AI behaviors
- Performance optimization for 100+ concurrent entities
- Object pooling for projectiles
- Advanced item effects and weapon upgrades

### Planned Features:
- Slot machine mechanics with dual currency system (credits vs coins)
- Meta-progression and unlock system
- Advanced enemy behaviors with rarity-based scaling
- Augment system for legendary once-per-run upgrades

## Technical Challenges Overcome

Based on actual development experience:

### Architecture Evolution
- **Initial system connectivity issues** - Early struggle connecting GameManager, Hangar, and Level systems
- **Collision system debugging** - Fixed bullets not hitting enemies through proper collision layer/mask setup
- **Player stat system scalability** - Refactored from hardcoded stats to flexible, JSON-driven system

### Combat System Refinement
- **Movement and firing balance** - Implemented stop-to-fire mechanics, then removed for better flow
- **Input buffering complexity** - Added movement buffer system for smooth kiting behavior
- **Attack speed scaling** - Separated bullet-specific fire rates from global attack speed

### Weapon System Development
- **Laser chain targeting bugs** - Fixed enemy death mid-chain causing system errors
- **Explosion detection issues** - Resolved collision detection problems with area damage
- **Double explosion bug** - Fixed missile explosions triggering multiple times near player

### UI and Data Management
- **Hangar scene integration** - Multiple iterations to achieve proper UI positioning and logic
- **Item persistence** - Rebuilt entire save system for better item data handling
- **Store randomization** - Implemented reroll mechanics and rarity-based item selection

### Performance and Polish
- **Damage label lifecycle** - Resolved memory issues with floating damage numbers
- **Enemy scaling system** - Built modular enemy stats that scale with power level
- **Movement system iterations** - Multiple refinements from click-to-move to hold-to-move

## Key Technical Implementations

### Weapon System Architecture
Four distinct weapon families with shared inheritance:
- **BulletWeapon** - Traditional projectiles with piercing and speed modifiers
- **LaserWeapon** - Chain targeting with reflection mechanics
- **RocketWeapon** - Explosive area damage with radius scaling
- **BioWeapon** - Damage-over-time effects with infection spread

### Component Communication
- BlinkSystem emits player_blinked signal for behavior effects
- PassiveEffectManager spawns and manages item behavior scripts
- WeaponSystem manages weapon lifecycle without tight coupling
- Enemy death triggers credit drops and infection spread

### Performance Considerations
- Currently optimizing laser chain targeting (reducing per-frame enemy queries)
- Implementing object pooling for frequently spawned projectiles
- Monitoring entity counts for large-scale combat scenarios
- Damage number merging system to reduce UI overhead

## Development Philosophy

This project demonstrates iterative problem-solving and architecture evolution:

- **Iterative refinement** - Features rebuilt multiple times based on gameplay feel
- **Component-based thinking** - Broke monolithic Player into specialized subsystems
- **Performance-first approach** - Proactive optimization rather than reactive fixes
- **Data-driven design** - Moved from hardcoded values to JSON configuration
- **Clean code principles** - Regular refactoring for maintainability

The commit history shows real software development: false starts, refactoring, bug fixes, and gradual improvement of both code quality and game feel.

## Known Technical Challenges

1. **Chain laser optimization** - Current implementation queries all enemies per frame
2. **Memory management** - Floating damage numbers require careful lifecycle management
3. **Scalability testing** - Target of 100+ concurrent enemies not yet stress-tested
4. **Enemy system performance** - Modular AI components need optimization for large counts

## How to Run

1. Install Godot Engine 4.3+
2. Clone repository and open project.godot
3. Run the main scene to access the level
4. Use mouse for movement/blinking, weapons auto-fire

**Controls:** Right-click (move), Left-click/F (blink), Space (hold to follow cursor)

## Development Timeline

- **April 2025:** Project inception, basic player movement, initial system connectivity issues
- **May 2025:** Component system architecture, weapon families, combat system refinement
- **June 2025:** Item system, store mechanics, enemy scaling system, current state

## Technologies Used

- **Engine:** Godot Engine 4.3
- **Language:** GDScript
- **Architecture:** Component-based design with manual dependency injection
- **Data:** JSON-driven configuration system
- **Performance:** Signal-based loose coupling, planned object pooling

---

*This project demonstrates practical application of software engineering principles in game development, with emphasis on clean architecture over rapid content creation.*
