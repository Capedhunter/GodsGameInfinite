class_name BattleManager
extends Node

signal battle_updated
signal battle_finished(victory: bool)

var player: BattleUnit
var enemy: BattleEnemy
var skills: Array[BattleSkill] = []
var battle_over := false
var turn_number := 1

func start_battle() -> void:
    player = BattleUnit.new()
    player.unit_name = "Protagonist"
    player.max_hp = 100
    player.max_sp = 30
    player.strength = 12
    player.magic = 12
    player.defense = 4
    player.agility = 12
    player.luck = 10
    player.combat_data = CharacterCombatData.new()
    player.combat_data.innate_proficiency["fire"] = 3
    player.combat_data.innate_proficiency["physical"] = 2
    player.setup()

    enemy = BattleEnemy.new()
    enemy.unit_name = "Void Echo"
    enemy.max_hp = 75
    enemy.strength = 10
    enemy.magic = 10
    enemy.defense = 2
    enemy.agility = 8
    enemy.luck = 5
    enemy.affinities = AffinityProfile.new()
    enemy.affinities.set_affinity("fire", CombatRules.Affinity.WEAK)
    enemy.setup()

    skills.clear()
    skills.append(_make_skill("Ember", "Fire damage. Strong against Void Echo.", 4, 18, "fire"))
    skills.append(_make_skill("Arc", "Legacy prototype damage skill.", 5, 21, "none"))
    skills.append(_make_skill("Mend", "Restore HP.", 5, 20, "none", true))
    skills.append(_make_skill("Focus", "Restore SP.", 0, 8, "none", false, true))
    battle_over = false
    turn_number = 1
    battle_updated.emit()

func _make_skill(skill_name: String, description: String, cost: int, power: int, damage_type: String, heals := false, restores_sp := false) -> BattleSkill:
    var skill := BattleSkill.new()
    skill.skill_name = skill_name
    skill.description = description
    skill.sp_cost = cost
    skill.power = power
    skill.damage_type = damage_type
    skill.heals = heals
    skill.restores_sp = restores_sp
    return skill

func player_attack() -> String:
    if not _can_act():
        return ""

    # Basic Attack is deliberately typeless: it does not use proficiency or affinity.
    var raw_damage := player.strength
    var defense_factor := 100.0 / (100.0 + maxf(0.0, float(enemy.defense)))
    var critical := randf() < (0.05 + (float(player.luck) * 0.01))
    var final_damage := int(round(float(raw_damage) * (1.5 if critical else 1.0) * defense_factor))
    final_damage = maxi(1, final_damage)
    enemy.hp = maxi(0, enemy.hp - final_damage)

    var result := "Attack dealt %d damage." % final_damage
    if critical:
        result = "CRITICAL! " + result
    return _finish_player_action(result)

func player_skill(index: int) -> String:
    if not _can_act() or index < 0 or index >= skills.size():
        return ""

    var skill := skills[index]
    var effective_sp_cost := _get_effective_sp_cost(skill)
    if not player.spend_sp(effective_sp_cost):
        return "Not enough SP."

    var result := ""
    if skill.heals:
        result = "%s restored %d HP." % [skill.skill_name, player.heal(skill.power)]
    elif skill.restores_sp:
        result = "%s restored %d SP." % [skill.skill_name, player.restore_sp(skill.power)]
    elif skill.damage_type == "none":
        # Temporary compatibility for the old prototype while the skill library is rebuilt.
        var defense_factor := 100.0 / (100.0 + maxf(0.0, float(enemy.defense)))
        var damage := maxi(1, int(round(float(skill.power) * defense_factor)))
        enemy.hp = maxi(0, enemy.hp - damage)
        result = "%s dealt %d damage." % [skill.skill_name, damage]
    else:
        if skill.is_hp_cost_skill():
            var hp_cost := maxi(1, int(ceil(float(player.max_hp) * skill.hp_cost_percent)))
            player.hp = maxi(1, player.hp - hp_cost)

        var hit := enemy.take_typed_damage(
            skill.power * player.magic / 10,
            skill.damage_type,
            true
        )
        var damage: int = hit.damage
        result = "%s dealt %d damage." % [skill.skill_name, damage]

        if hit.affinity == CombatRules.Affinity.WEAK:
            result += " WEAK!"
        elif hit.affinity == CombatRules.Affinity.ENDANGER:
            result += " ENDANGERED! DOWN!"
        elif hit.affinity == CombatRules.Affinity.RESIST:
            result += " RESIST."
        elif hit.affinity in [CombatRules.Affinity.NULL, CombatRules.Affinity.REPEL, CombatRules.Affinity.DRAIN]:
            result += " BLOCKED."

        if hit.critical:
            result += " CRITICAL!"

    return _finish_player_action(result)

func _get_effective_sp_cost(skill: BattleSkill) -> int:
    if skill.sp_cost <= 0:
        return 0
    if not skill.is_damage_skill() or skill.damage_type == "judgment":
        return skill.sp_cost
    var proficiency := player.get_proficiency(skill.damage_type)
    return maxi(1, int(ceil(float(skill.sp_cost) * CombatRules.proficiency_sp_multiplier(proficiency))))

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
    return result + "\n" + enemy_result

func _enemy_turn() -> String:
    var hit := player.take_typed_damage(enemy.strength, "melee", false)
    var damage: int = hit.damage
    if not player.is_alive():
        battle_over = true
        battle_finished.emit(false)
        return "Void Echo attacked for %d damage. You were defeated." % damage
    return "Void Echo attacked for %d damage." % damage

func _can_act() -> bool:
    return not battle_over and player != null and enemy != null and player.is_alive() and enemy.is_alive()
