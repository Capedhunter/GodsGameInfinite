class_name BattleUnit
extends Resource

## Combatant data used by the first playable battle prototype.

@export var unit_name: String = "Unit"
@export var max_hp: int = 100
@export var hp: int = 100
@export var max_sp: int = 30
@export var sp: int = 30
@export var attack_power: int = 10
@export var defense: int = 5
@export var is_guarding: bool = false

func setup() -> void:
    hp = max_hp
    sp = max_sp
    is_guarding = false

func take_damage(amount: int) -> int:
    var final_damage := maxi(1, amount - defense)
    if is_guarding:
        final_damage = maxi(1, int(ceil(final_damage * 0.5)))
        is_guarding = false
    hp = maxi(0, hp - final_damage)
    return final_damage

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
