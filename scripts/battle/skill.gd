class_name BattleSkill
extends Resource

@export var skill_name: String = "Skill"
@export var description: String = ""
@export var sp_cost: int = 0
@export var hp_cost_percent: float = 0.0
@export var power: int = 0
@export var damage_type: String = "none"
@export var heals: bool = false
@export var restores_sp: bool = false

func is_damage_skill() -> bool:
    return CombatRules.is_valid_damage_type(damage_type)

func is_hp_cost_skill() -> bool:
    return damage_type in ["physical", "ranged", "melee"] and hp_cost_percent > 0.0
