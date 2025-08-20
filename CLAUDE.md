# Void Gambit - Godot Space Shooter

## Project Overview
Space shooter game built in Godot with roguelike elements including slot machine mechanics, item progression, and wave-based enemy spawning.

## Developer Preferences
- **Avoid autoloads** - Developer prefers not to work with Godot autoload systems
- **Avoid UI work** - Developer dislikes working on user interface elements
- **Professional code style** - No emojis in code, comments, or commit messages

## Project Structure
- `assets/` - Game sprites and images (enemies, player, weapons, backgrounds)
- `scenes/` - Godot scene files organized by type (actors, enemies, weapons, UI, effects)
- `scripts/` - GDScript files mirroring scene structure
- `data/` - JSON configuration files for game balance and progression
- `editor_scripts/` - Godot editor tools and utilities

## Key Systems
- **Enemy System**: Various enemy types with unique movement patterns and attacks
- **Weapon System**: Multiple weapon types including bullets, lasers, rockets, and bio weapons
- **Power Budget Spawning**: Dynamic enemy spawning based on power calculations
- **Progression**: Slot machine mechanics and store system for upgrades
- **Wave Management**: Progressive difficulty through wave system

## Code Organization
- Enemy scripts organized by type (base-enemy, enemy-scripts, movement, attacks)
- Player systems include movement, weapons, and blink mechanics
- Weapon spawners for ship-based weapons
- Comprehensive constants files for game balance