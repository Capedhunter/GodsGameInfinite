class_name CombatRules
extends RefCounted

const DAMAGE_TYPES := [
    "fire", "wind", "water", "earth", "electric", "ice",
    "light", "darkness", "physical", "ranged", "melee", "judgment"
]

const PROFICIENCY_LEVELS := ["very_weak", "weak", "normal", "strong", "master"]

enum Affinity {
    WEAK,
    NEUTRAL,
    RESIST,
    NULL,
    REPEL,
    DRAIN,
    ENDANGER
}

static func affinity_name(affinity: Affinity) -> String:
    return Affinity.keys()[affinity].capitalize()

static func is_valid_damage_type(damage_type: String) -> bool:
    return damage_type in DAMAGE_TYPES

static func is_proficiency_damage_type(damage_type: String) -> bool:
    return damage_type != "judgment" and is_valid_damage_type(damage_type)

static func proficiency_modifier(level: int) -> float:
    # Continuous scaling across the five visible proficiency tiers.
    return clampf(0.70 + (0.15 * float(level)), 0.70, 1.30)

static func proficiency_sp_multiplier(level: int) -> float:
    # Higher proficiency makes skills cheaper without eliminating their cost.
    return clampf(1.20 - (0.05 * float(level)), 1.00, 1.20)

static func physical_cost_multiplier(level: int) -> float:
    # Physical/Ranged/Melee HP costs benefit from the same proficiency curve.
    return clampf(1.20 - (0.05 * float(level)), 1.00, 1.20)

static func affinity_multiplier(affinity: Affinity) -> float:
    match affinity:
        Affinity.WEAK, Affinity.ENDANGER:
            return 1.70
        Affinity.RESIST:
            return 0.50
        Affinity.NULL, Affinity.REPEL, Affinity.DRAIN:
            return 0.0
        _:
            return 1.0
