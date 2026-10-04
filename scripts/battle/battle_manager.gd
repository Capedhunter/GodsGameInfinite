class_name BattleManager
extends Node

## First playable turn-based battle loop.
## Flow: player action -> enemy turn -> repeat -> victory/defeat.

signal battle_updated
signal battle_finished(victory: bool)

var player: BattleUnit
var enemy: BattleEnemy
var skills: Array[BattleSkill] = []
var battle_over := false
var busy := false
var turn_number := 1

func start_battle() -> void:
    player = BattleUnit.new()
    player.unit_name = "Protagonist"
    player.max_hp = 100
    player.max_sp = 30
    player.attack_power = 12
    player.defense = 4
    player.setup()

    enemy = BattleEnemy.new()
    enemy.unit_name = "Void Echo"
    enemy.max_hp = 75
    enemy.max_sp = 0
    enemy.attack_power = 10
    enemy.defense = 2
    enemy.weakness = "fire"
    enemy.setup()

    skills.clear()
    skills.append(_make_skill("Ember", "Fire damage. Strong against Void Echo.", 4, 18, "fire"))
    skills.append(_make_skill("Arc", "Reliable non-elemental damage.", 5, 21, "none"))
    skills.append(_make_skill("Mend", "Restore HP.", 5, 20, "heal", true))
    skills.append(_make_skill("Focus", "Restore SP for another skill.", 0, 8, "sp", false, true))

    battle_over = false
    busy = false
    turn_number = 1
    battle_updated.emit()

func _make_skill(skill_name: String, description: String, cost: int, power: int, element: String, heals := false, restores_sp := false) -> BattleSkill:
    var skill := BattleSkill.new()
    skill.skill_name = skill_name
    skill.description = description
    skill.sp_cost = cost
    skill.power = power
    skill.element = element
    skill.heals = heals
    skill.restores_sp = restores_sp
    return skill

func player_attack() -> String:
    if not _can_act():
        return ""
    var critical := randf() < 0.15
    var power := player.attack_power
    if critical:
        power *= 2
    var damage := enemy.take_damage(power)
    var result := "Attack dealt %d damage." % damage
    if critical:
        result = "CRITICAL! " + result
    return _finish_player_action(result)

func player_skill(index: int) -> String:
    if not _can_act() or index < 0 or index >= skills.size():
        return ""
    var skill := skills[index]
    if not player.spend_sp(skill.sp_cost):
        return "Not enough SP."

    var result := ""
    if skill.heals:
        var healed := player.heal(skill.power)
        result = "%s restored %d HP." % [skill.skill_name, healed]
    elif skill.restores_sp:
        var restored := player.restore_sp(skill.power)
        result = "%s restored %d SP." % [skill.skill_name, restored]
    else:
        var multiplier := 1.5 if skill.element == enemy.weakness else 1.0
        var critical := randf() < 0.10
        if critical:
            multiplier *= 1.5
        var damage := enemy.take_damage(int(round(skill.power * multiplier)))
        result = "%s dealt %d damage." % [skill.skill_name, damage]
        if skill.element == enemy.weakness:
            result += " WEAK!"
        if critical:
            result += " CRITICAL!"
    return _finish_player_action(result)

func player_guard() -> String:
    if not _can_act():
        return ""
    player.is_guarding = true
    return _finish_player_action("Guard raised. Incoming damage is reduced.")

func _finish_player_action(result: String) -> String:
    if not enemy.is_alive():
        battle_over = true
        battle_finished.emit(true)
        battle_updated.emit()
        return result + " Void Echo was defeated!"

    var enemy_result := _enemy_turn()
    turn_number += 1
    battle_updated.emit()
    return result + "
" + enemy_result

func _enemy_turn() -> String:
    if not enemy.is_alive():
        return ""
    var damage := player.take_damage(enemy.attack_power)
    if not player.is_alive():
        battle_over = true
        battle_finished.emit(false)
        return "Void Echo dealt %d damage. You were defeated." % damage
    return "Void Echo attacked for %d damage." % damage

func _can_act() -> bool:
    return not battle_over and not busy and player != null and enemy != null and player.is_alive() and enemy.is_alive()
