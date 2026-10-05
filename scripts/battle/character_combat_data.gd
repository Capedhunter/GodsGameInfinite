class_name CharacterCombatData
extends Resource

@export var strength: int = 10
@export var magic: int = 10
@export var defense: int = 10
@export var agility: int = 10
@export var luck: int = 10

# Innate proficiency growth is character-defined and therefore deterministic.
# The skill tree can add separate proficiency points on top of this growth.
@export var innate_proficiency: Dictionary = {
    "fire": 2,
    "wind": 2,
    "water": 2,
    "earth": 2,
    "electric": 2,
    "ice": 2,
    "light": 2,
    "darkness": 2,
    "physical": 2,
    "ranged": 2,
    "melee": 2
}

func get_proficiency(damage_type: String) -> int:
    if damage_type == "judgment":
        return -1
    return clampi(int(innate_proficiency.get(damage_type, 2)), 0, 4)
