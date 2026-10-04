class_name BattleEnemy
extends BattleUnit

## Enemy definition for the first playable battle.

@export var weakness: String = "fire"
@export var enemy_description: String = "A mysterious training enemy."

func get_display_name() -> String:
    return unit_name
