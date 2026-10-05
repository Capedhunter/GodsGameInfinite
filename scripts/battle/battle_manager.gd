class_name BattleManager
extends Node

signal battle_updated
signal battle_finished(victory: bool)

const PARTY_SIZE := 5
const MAX_ENEMIES := 3
const DOUBLE_ACTION_RATIO := 1.35

var party: Array[BattleUnit] = []
var enemies: Array[BattleEnemy] = []
var player: BattleUnit
var enemy: BattleEnemy
var skills: Array[BattleSkill] = []
var battle_over := false
var turn_number := 0
var round_number := 0
var turn_queue: Array[Dictionary] = []
var current_actor: BattleUnit
var waiting_for_player := false

func start_battle() -> void:
    _build_party()
    _build_enemies()
    skills.clear()
    skills.append(_make_skill("Ember", "Fire damage. Strong against Void Echo.", 4, 18, "fire"))
    skills.append(_make_skill("Arc", "Legacy prototype damage skill.", 5, 21, "none"))
    skills.append(_make_skill("Mend", "Restore HP.", 5, 20, "none", true))
    skills.append(_make_skill("Focus", "Restore SP.", 0, 8, "none", false, true))
    battle_over = false
    turn_number = 0
    round_number = 0
    turn_queue.clear()
    current_actor = null
    waiting_for_player = false
    _start_round()
    battle_updated.emit()
    _process_ai_turns()

func _build_party() -> void:
    party.clear()

    player = _make_party_member("Protagonist", 100, 30, 16, 10, 13, 12, 10)
    player.combat_data.innate_proficiency["fire"] = 3
    player.combat_data.innate_proficiency["physical"] = 2
    party.append(player)

    party.append(_make_party_member("Mary", 95, 38, 10, 16, 12, 9, 12))
    party.append(_make_party_member("Aradia", 90, 42, 9, 17, 10, 14, 13))
    party.append(_make_party_member("Valentin", 115, 28, 18, 10, 15, 11, 9))
    party.append(_make_party_member("Frederick", 100, 34, 13, 13, 11, 13, 14))

func _make_party_member(member_name: String, hp: int, sp: int, strength: int, magic: int, defense: int, agility: int, luck: int) -> BattleUnit:
    var member := BattleUnit.new()
    member.unit_name = member_name
    member.max_hp = hp
    member.max_sp = sp
    member.strength = strength
    member.magic = magic
    member.defense = defense
    member.agility = agility
    member.luck = luck
    member.combat_data = CharacterCombatData.new()
    member.setup()
    return member

func _build_enemies() -> void:
    enemies.clear()
    enemies.append(_make_enemy("Void Echo", 75, 10, 10, 2, 8, 5, "fire", CombatRules.Affinity.WEAK))
    enemies.append(_make_enemy("Hollow Shade", 60, 12, 8, 4, 11, 7, "ice", CombatRules.Affinity.WEAK))
    enemies.append(_make_enemy("Static Wraith", 55, 9, 9, 3, 15, 6, "wind", CombatRules.Affinity.WEAK))
    enemy = enemies[0]

func _make_enemy(enemy_name: String, hp: int, strength: int, magic: int, defense: int, agility: int, luck: int, weak_type: String, weak_affinity: CombatRules.Affinity) -> BattleEnemy:
    var unit := BattleEnemy.new()
    unit.unit_name = enemy_name
    unit.max_hp = hp
    unit.strength = strength
    unit.magic = magic
    unit.defense = defense
    unit.agility = agility
    unit.luck = luck
    unit.affinities = AffinityProfile.new()
    unit.affinities.set_affinity(weak_type, weak_affinity)
    unit.setup()
    return unit

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

func _start_round() -> void:
    if battle_over:
        return

    turn_queue.clear()
    var all_units: Array[BattleUnit] = []
    for member in party:
        if member.is_alive():
            all_units.append(member)
    for foe in enemies:
        if foe.is_alive():
            all_units.append(foe)

    for unit in all_units:
        var action_count := _get_action_count(unit)
        for action_index in action_count:
            turn_queue.append({
                "unit": unit,
                "action_index": action_index
            })

    _sort_turn_queue()
    round_number += 1

func _get_action_count(unit: BattleUnit) -> int:
    var opposing_agility := 0.0
    var opposing_count := 0

    if unit in party:
        for foe in enemies:
            if foe.is_alive():
                opposing_agility += foe.agility
                opposing_count += 1
    else:
        for member in party:
            if member.is_alive():
                opposing_agility += member.agility
                opposing_count += 1

    if opposing_count == 0:
        return 1

    var average_opposing_agility := opposing_agility / float(opposing_count)
    return 2 if float(unit.agility) >= average_opposing_agility * DOUBLE_ACTION_RATIO else 1

func _sort_turn_queue() -> void:
    turn_queue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        var a_unit: BattleUnit = a.unit
        var b_unit: BattleUnit = b.unit
        if a.action_index != b.action_index:
            return a.action_index < b.action_index
        if a_unit.agility != b_unit.agility:
            return a_unit.agility > b_unit.agility
        return a_unit.unit_name < b_unit.unit_name
    )

func _next_actor() -> void:
    if battle_over:
        return

    if turn_queue.is_empty():
        _start_round()

    if turn_queue.is_empty():
        return

    var entry: Dictionary = turn_queue.pop_front()
    current_actor = entry.unit

    if not current_actor.is_alive():
        _next_actor()
        return

    turn_number += 1
    waiting_for_player = current_actor == player
    battle_updated.emit()

func _process_ai_turns() -> String:
    if battle_over:
        return ""

    var results: Array[String] = []
    _next_actor()
    while not battle_over and current_actor != null and current_actor != player:
        var result := _ai_take_turn(current_actor)
        if result != "":
            results.append(result)
        if battle_over:
            return "\n".join(results)
        _next_actor()
    return "\n".join(results)

func _ai_take_turn(actor: BattleUnit) -> String:
    if actor in party:
        var target := _first_living_enemy()
        if target == null:
            return ""
        return _basic_attack(actor, target)
    else:
        var target := _first_living_party_member()
        if target == null:
            return ""
        return _basic_attack(actor, target)

func _basic_attack(attacker: BattleUnit, target: BattleUnit) -> String:
    var raw_damage := attacker.strength
    var defense_factor := 100.0 / (100.0 + maxf(0.0, float(target.defense)))
    var critical := randf() < (0.05 + (float(attacker.luck) * 0.01))
    var final_damage := int(round(float(raw_damage) * (1.5 if critical else 1.0) * defense_factor))
    final_damage = maxi(1, final_damage)

    if target.is_guarding:
        final_damage = maxi(1, int(ceil(float(final_damage) * 0.5)))
        target.is_guarding = false

    target.hp = maxi(0, target.hp - final_damage)
    var result := "%s attacked %s for %d damage." % [attacker.unit_name, target.unit_name, final_damage]
    if critical:
        result = "CRITICAL! " + result
    _check_battle_state()
    return result

func player_attack() -> String:
    if not _can_player_act():
        return ""

    var target := _first_living_enemy()
    if target == null:
        return ""

    var raw_damage := player.strength
    var defense_factor := 100.0 / (100.0 + maxf(0.0, float(target.defense)))
    var critical := randf() < (0.05 + (float(player.luck) * 0.01))
    var final_damage := int(round(float(raw_damage) * (1.5 if critical else 1.0) * defense_factor))
    final_damage = maxi(1, final_damage)
    target.hp = maxi(0, target.hp - final_damage)

    var result := "Attack dealt %d damage to %s." % [final_damage, target.unit_name]
    if critical:
        result = "CRITICAL! " + result
    return _finish_player_action(result)

func player_skill(index: int) -> String:
    if not _can_player_act() or index < 0 or index >= skills.size():
        return ""

    var skill := skills[index]
    var effective_sp_cost := _get_effective_sp_cost(skill)
    if not player.spend_sp(effective_sp_cost):
        return "Not enough SP."

    var target := _first_living_enemy()
    var result := ""
    if skill.heals:
        result = "%s restored %d HP." % [skill.skill_name, player.heal(skill.power)]
    elif skill.restores_sp:
        result = "%s restored %d SP." % [skill.skill_name, player.restore_sp(skill.power)]
    elif skill.damage_type == "none":
        if target == null:
            return ""
        var defense_factor := 100.0 / (100.0 + maxf(0.0, float(target.defense)))
        var damage := maxi(1, int(round(float(skill.power) * defense_factor)))
        target.hp = maxi(0, target.hp - damage)
        result = "%s dealt %d damage to %s." % [skill.skill_name, damage, target.unit_name]
    else:
        if target == null:
            return ""
        if skill.is_hp_cost_skill():
            var hp_cost := maxi(1, int(ceil(float(player.max_hp) * skill.hp_cost_percent)))
            player.hp = maxi(1, player.hp - hp_cost)

        var hit := target.take_typed_damage(
            int(round(float(skill.power) * float(player.magic) / 10.0)),
            skill.damage_type,
            true
        )
        var damage: int = hit.damage
        result = "%s dealt %d damage to %s." % [skill.skill_name, damage, target.unit_name]

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

func player_guard() -> String:
    if not _can_player_act():
        return ""
    player.is_guarding = true
    return _finish_player_action("Guard raised. Incoming damage is reduced.")

func player_skip() -> String:
    if not _can_player_act():
        return ""
    return _finish_player_action("Protagonist skipped the action.")

func _get_effective_sp_cost(skill: BattleSkill) -> int:
    if skill.sp_cost <= 0:
        return 0
    if not skill.is_damage_skill() or skill.damage_type == "judgment":
        return skill.sp_cost
    var proficiency := player.get_proficiency(skill.damage_type)
    return maxi(1, int(ceil(float(skill.sp_cost) * CombatRules.proficiency_sp_multiplier(proficiency))))

func _finish_player_action(result: String) -> String:
    _check_battle_state()
    if battle_over:
        battle_updated.emit()
        return result

    var ai_results := _process_ai_turns()
    battle_updated.emit()
    if ai_results != "":
        return result + "\n" + ai_results
    return result

func _check_battle_state() -> void:
    if battle_over:
        return

    var any_enemy_alive := false
    for foe in enemies:
        if foe.is_alive():
            any_enemy_alive = true
            break

    if not any_enemy_alive:
        battle_over = true
        battle_finished.emit(true)
        return

    var any_party_alive := false
    for member in party:
        if member.is_alive():
            any_party_alive = true
            break

    if not any_party_alive:
        battle_over = true
        battle_finished.emit(false)

func _can_player_act() -> bool:
    return not battle_over and waiting_for_player and current_actor == player and player.is_alive() and _first_living_enemy() != null

func _first_living_enemy() -> BattleEnemy:
    for foe in enemies:
        if foe.is_alive():
            return foe
    return null

func _first_living_party_member() -> BattleUnit:
    for member in party:
        if member.is_alive():
            return member
    return null

func get_turn_order_names() -> Array[String]:
    var names: Array[String] = []
    if current_actor != null and current_actor.is_alive():
        names.append(current_actor.unit_name + " (NOW)")
    for entry in turn_queue:
        var unit: BattleUnit = entry.unit
        if unit.is_alive():
            names.append(unit.unit_name)
    return names

