extends Control

var manager: BattleManager
var log_label: Label
var hp_label: Label
var sp_label: Label
var enemy_hp_label: Label
var turn_label: Label
var turn_order_label: Label
var enemy_list_label: Label
var skill_buttons: Array[Button] = []
var action_buttons: Array[Button] = []
var victory_panel: PanelContainer

func _ready() -> void:
    manager = get_parent().get_node("BattleManager")
    manager.battle_updated.connect(_refresh)
    manager.battle_finished.connect(_on_battle_finished)
    _build_ui()
    manager.start_battle()

func _build_ui() -> void:
    var title := Label.new()
    title.text = "BATTLE"
    title.position = Vector2(60, 35)
    title.add_theme_font_size_override("font_size", 34)
    add_child(title)

    turn_label = _label(Vector2(60, 80), 20)
    turn_order_label = _label(Vector2(60, 115), 18)
    turn_order_label.size = Vector2(760, 90)
    turn_order_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    var enemy_title := Label.new()
    enemy_title.text = "ENEMIES"
    enemy_title.position = Vector2(900, 90)
    enemy_title.add_theme_font_size_override("font_size", 24)
    add_child(enemy_title)

    enemy_list_label = _label(Vector2(900, 130), 18)
    enemy_list_label.size = Vector2(300, 170)
    enemy_list_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    hp_label = _label(Vector2(60, 455), 20)
    sp_label = _label(Vector2(60, 490), 20)

    log_label = _label(Vector2(410, 405), 17)
    log_label.size = Vector2(500, 120)
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    var actions := HBoxContainer.new()
    actions.position = Vector2(60, 575)
    actions.add_theme_constant_override("separation", 6)
    add_child(actions)

    _add_action(actions, "Attack", _on_attack)
    _add_action(actions, "Guard", _on_guard)
    for i in 4:
        var button := Button.new()
        button.custom_minimum_size = Vector2(125, 44)
        button.pressed.connect(_on_skill.bind(i))
        actions.add_child(button)
        skill_buttons.append(button)

    _add_action(actions, "Skip", _on_skip)

    victory_panel = PanelContainer.new()
    victory_panel.position = Vector2(410, 240)
    victory_panel.size = Vector2(420, 150)
    victory_panel.visible = false
    add_child(victory_panel)
    var text := Label.new()
    text.text = "VICTORY!\n\nPress Enter to return to the overworld."
    text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    text.add_theme_font_size_override("font_size", 24)
    victory_panel.add_child(text)

func _label(pos: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.position = pos
    label.add_theme_font_size_override("font_size", font_size)
    add_child(label)
    return label

func _add_action(parent: Container, text_value: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(100, 44)
    button.pressed.connect(callback)
    parent.add_child(button)
    action_buttons.append(button)

func _on_attack() -> void:
    _show_result(manager.player_attack())

func _on_guard() -> void:
    _show_result(manager.player_guard())

func _on_skill(index: int) -> void:
    _show_result(manager.player_skill(index))

func _on_skip() -> void:
    _show_result(manager.player_skip())

func _show_result(result: String) -> void:
    if result != "":
        log_label.text = result
    _refresh()

func _refresh() -> void:
    if manager == null or manager.player == null:
        return

    hp_label.text = "PROTAGONIST  HP %d / %d" % [manager.player.hp, manager.player.max_hp]
    sp_label.text = "SP %d / %d" % [manager.player.sp, manager.player.max_sp]
    turn_label.text = "ROUND %d  •  TURN %d  •  %s" % [
        manager.round_number,
        manager.turn_number,
        "YOUR ACTION" if manager.current_actor == manager.player else "WAIT"
    ]

    var order := manager.get_turn_order_names()
    turn_order_label.text = "TURN ORDER: " + "  →  ".join(order)

    var enemy_text := ""
    for foe in manager.enemies:
        var state := "DEFEATED" if not foe.is_alive() else "HP %d / %d" % [foe.hp, foe.max_hp]
        enemy_text += "%s  —  %s\n" % [foe.unit_name, state]
    enemy_list_label.text = enemy_text

    var can_act := manager.current_actor == manager.player and manager.waiting_for_player and not manager.battle_over
    for i in skill_buttons.size():
        if i >= manager.skills.size():
            continue
        var skill: BattleSkill = manager.skills[i]
        skill_buttons[i].text = "%s [%d SP]" % [skill.skill_name, skill.sp_cost]
        skill_buttons[i].tooltip_text = skill.description
        skill_buttons[i].disabled = not can_act or manager.player.sp < manager._get_effective_sp_cost(skill)
    for button in action_buttons:
        button.disabled = not can_act

func _on_battle_finished(victory: bool) -> void:
    if victory:
        victory_panel.visible = true
        for button in action_buttons:
            button.disabled = true
        for button in skill_buttons:
            button.disabled = true
    else:
        get_tree().change_scene_to_file("res://scenes/world/World.tscn")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and victory_panel.visible:
        get_tree().change_scene_to_file("res://scenes/world/World.tscn")
