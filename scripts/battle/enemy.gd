class_name BattleEnemy
extends BattleUnit

@export var enemy_description: String = "A mysterious training enemy."

func get_display_name() -> String:
    return unit_name
