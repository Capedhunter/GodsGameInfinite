class_name AffinityProfile
extends Resource

@export var affinities: Dictionary = {
    "fire": CombatRules.Affinity.NEUTRAL,
    "wind": CombatRules.Affinity.NEUTRAL,
    "water": CombatRules.Affinity.NEUTRAL,
    "earth": CombatRules.Affinity.NEUTRAL,
    "electric": CombatRules.Affinity.NEUTRAL,
    "ice": CombatRules.Affinity.NEUTRAL,
    "light": CombatRules.Affinity.NEUTRAL,
    "darkness": CombatRules.Affinity.NEUTRAL,
    "physical": CombatRules.Affinity.NEUTRAL,
    "ranged": CombatRules.Affinity.NEUTRAL,
    "melee": CombatRules.Affinity.NEUTRAL,
    "judgment": CombatRules.Affinity.NEUTRAL
}

func get_affinity(damage_type: String) -> CombatRules.Affinity:
    return affinities.get(damage_type, CombatRules.Affinity.NEUTRAL)

func set_affinity(damage_type: String, affinity: CombatRules.Affinity) -> void:
    if CombatRules.is_valid_damage_type(damage_type):
        affinities[damage_type] = affinity
