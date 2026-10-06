# God's Game: Infinite

A Godot-based turn-based RPG / narrative game.

## Architecture

- `scenes/` — reusable Godot scenes
- `scripts/core/` — global game and scene management
- `scripts/player/` — player systems
- `scripts/world/` — overworld systems
- `scripts/battle/` — turn-based combat systems
- `scripts/dialogue/` — dialogue systems
- `scripts/sponsors/` — Sponsor data and Sponsor-specific systems
- `data/` — data-driven resources for characters, enemies, skills, sponsors, quests, and items
- `assets/` — art, audio, environments, UI, and VFX
- `addons/` — optional Godot plugins

## Sponsor foundation

Sponsors are manifestations of humanity's perception of myths, legends, theological figures, and other enduring cultural ideas. They are not literally the historical or mythological figures they are based on.

A Sponsor has its own personality and can speak with its chosen character, advise them, criticize them, and develop a relationship with them. Sponsors always follow their chosen character's commands; their agency is expressed through personality and dialogue rather than control.

The first prototype Sponsor is **Heracles**, a warrior-oriented manifestation designed for Valentin. Heracles emphasizes Physical/Melee combat, strength, perseverance, and overcoming trials.

Sponsor data is intentionally separated from battle logic so additional Sponsors can be created as reusable resources without rewriting the combat system.

## Development principle

Keep game data separate from gameplay logic so new characters, enemies, skills, sponsors, and quests can be added without rewriting core systems.

## Current milestone

Project foundation and incremental gameplay systems. The Sponsor data foundation and first prototype Sponsor are now established.
