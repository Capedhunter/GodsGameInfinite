class_name BattleUnit
extends Resource

@export var unit_name: String = "Unit"
@export var max_hp: int = 100
@export var hp: int = 100
@export var max_sp: int = 30
@export var sp: int = 30
@export var strength: int = 10
@export var magic: int = 10
@export var defense: int = 5
@export var agility: int = 10
@export var luck: int = 10
@export var is_guarding: bool = false
@export var affinities: AffinityProfile
@export var combat_data: CharacterCombatData
@export var personal_skills: Array[BattleSkill] = []

func setup() -> void:
    hp = max_hp
    sp = max_sp
    is_guarding = false
    if affinities == null:
        affinities = AffinityProfile.new()
    if combat_data == null:
        combat_data = CharacterCombatData.new()

func get_affinity(damage_type: String) -> CombatRules.Affinity:
    if affinities == null:
        return CombatRules.Affinity.NEUTRAL
    return affinities.get_affinity(damage_type)

func get_proficiency(damage_type: String) -> int:
    if combat_data == null:
        return 2
    return combat_data.get_proficiency(damage_type)

func take_damage(amount: int) -> int:
    var final_damage := maxi(1, amount - defense)
    if is_guarding:
        final_damage = maxi(1, int(ceil(final_damage * 0.5)))
        is_guarding = false
    hp = maxi(0, hp - final_damage)
    return final_damage

func take_typed_damage(base_power: int, damage_type: String, can_crit := false, damage_bonus_multiplier: float = 1.0) -> Dictionary:
    var affinity := get_affinity(damage_type)
    var critical := can_crit and randf() < (0.05 + (float(luck) * 0.01))

    # Null/Repel/Drain override criticals completely.
    if affinity in [CombatRules.Affinity.NULL, CombatRules.Affinity.REPEL, CombatRules.Affinity.DRAIN]:
        return {"damage": 0, "affinity": affinity, "critical": false, "blocked": true}

    var proficiency := get_proficiency(damage_type)
    var proficiency_multiplier := 1.0 if damage_type == "judgment" else CombatRules.proficiency_modifier(proficiency)
    var affinity_multiplier := 1.0 if critical else CombatRules.affinity_multiplier(affinity)

    # Defense and affinity are deliberately combined rather than treated as two
    # independent sequential reductions.
    var raw_damage := float(base_power) * proficiency_multiplier * affinity_multiplier
    var defense_factor := 100.0 / (100.0 + maxf(0.0, float(defense)))
    var normal_damage := maxi(1, int(round(raw_damage * defense_factor)))
    var final_damage := maxi(1, int(round(raw_damage * damage_bonus_multiplier * defense_factor)))

    if is_guarding:
        final_damage = maxi(1, int(ceil(final_damage * 0.5)))
        is_guarding = false

    hp = maxi(0, hp - final_damage)
    return {
        "damage": final_damage,
        "normal_damage": normal_damage,
        "affinity": affinity,
        "critical": critical,
        "blocked": false,
        "proficiency": proficiency
    }

func heal(amount: int) -> int:
    var old_hp := hp
    hp = mini(max_hp, hp + amount)
    return hp - old_hp

func spend_sp(amount: int) -> bool:
    if sp < amount:
        return false
    sp -= amount
    return true

func restore_sp(amount: int) -> int:
    var old_sp := sp
    sp = mini(max_sp, sp + amount)
    return sp - old_sp

func is_alive() -> bool:
    return hp > 0
