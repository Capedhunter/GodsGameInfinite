# God's Game: Infinite

A Godot-based turn-based RPG / narrative game.

## Architecture

- `scenes/` — reusable Godot scenes
- `scripts/core/` — global game and scene management
- `scripts/player/` — player systems
- `scripts/world/` — overworld systems
- `scripts/battle/` — turn-based combat systems
- `scripts/dialogue/` — dialogue systems
- `data/` — data-driven resources for characters, enemies, skills, sponsors, quests, and items
- `assets/` — art, audio, environments, UI, and VFX
- `addons/` — optional Godot plugins

## Development principle

Keep game data separate from gameplay logic so new characters, enemies, skills, sponsors, and quests can be added without rewriting core systems.

## Current milestone

Project foundation and directory architecture. Gameplay systems will be added incrementally.
