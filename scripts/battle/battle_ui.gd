extends Control

var manager: BattleManager
var log_label: Label
var active_name_label: Label
var hp_label: Label
var sp_label: Label
var turn_label: Label
var turn_order_label: Label
var enemy_title_label: Label
var enemy_buttons: Array[Button] = []
var command_buttons: Array[Button] = []
var skill_buttons: Array[Button] = []
var target_mode := false
var pending_skill_index := -1
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
    title.position = Vector2(50, 28)
    title.add_theme_font_size_override("font_size", 32)
    add_child(title)

    turn_label = _label(Vector2(50, 70), 18)
    turn_order_label = _label(Vector2(50, 105), 17)
    turn_order_label.size = Vector2(1050, 42)
    turn_order_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    var active_panel := PanelContainer.new()
    active_panel.position = Vector2(50, 175)
    active_panel.size = Vector2(310, 170)
    add_child(active_panel)

    var active_box := VBoxContainer.new()
    active_box.add_theme_constant_override("separation", 8)
    active_panel.add_child(active_box)

    var active_header := Label.new()
    active_header.text = "ACTIVE CHARACTER"
    active_header.add_theme_font_size_override("font_size", 16)
    active_box.add_child(active_header)

    active_name_label = Label.new()
    active_name_label.add_theme_font_size_override("font_size", 25)
    active_box.add_child(active_name_label)

    hp_label = Label.new()
    hp_label.add_theme_font_size_override("font_size", 18)
    active_box.add_child(hp_label)

    sp_label = Label.new()
    sp_label.add_theme_font_size_override("font_size", 18)
    active_box.add_child(sp_label)

    var command_panel := PanelContainer.new()
    command_panel.position = Vector2(50, 365)
    command_panel.size = Vector2(310, 250)
    add_child(command_panel)

    var command_box := VBoxContainer.new()
    command_box.add_theme_constant_override("separation", 6)
    command_panel.add_child(command_box)

    var command_title := Label.new()
    command_title.text = "COMMAND"
    command_title.add_theme_font_size_override("font_size", 16)
    command_box.add_child(command_title)

    _add_command(command_box, "Attack", _on_attack)
    for i in 4:
        var button := Button.new()
        button.custom_minimum_size = Vector2(280, 38)
        button.pressed.connect(_on_skill.bind(i))
        command_box.add_child(button)
        skill_buttons.append(button)

    _add_command(command_box, "Guard", _on_guard)
    _add_command(command_box, "Skip", _on_skip)

    var enemy_panel := PanelContainer.new()
    enemy_panel.position = Vector2(405, 175)
    enemy_panel.size = Vector2(650, 250)
    add_child(enemy_panel)

    var enemy_box := VBoxContainer.new()
    enemy_box.add_theme_constant_override("separation", 8)
    enemy_panel.add_child(enemy_box)

    enemy_title_label = Label.new()
    enemy_title_label.text = "CHOOSE TARGET"
    enemy_title_label.add_theme_font_size_override("font_size", 22)
    enemy_box.add_child(enemy_title_label)

    for i in 3:
        var button := Button.new()
        button.custom_minimum_size = Vector2(600, 48)
        button.pressed.connect(_on_target_selected.bind(i))
        enemy_box.add_child(button)
        enemy_buttons.append(button)

    log_label = _label(Vector2(405, 455), 17)
    log_label.size = Vector2(650, 145)
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    victory_panel = PanelContainer.new()
    victory_panel.position = Vector2(405, 270)
    victory_panel.size = Vector2(420, 150)
    victory_panel.visible = false
    add_child(victory_panel)

    var victory_text := Label.new()
    victory_text.text = "VICTORY!\n\nPress Enter to return to the overworld."
    victory_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    victory_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    victory_text.add_theme_font_size_override("font_size", 24)
    victory_panel.add_child(victory_text)

func _label(pos: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.position = pos
    label.add_theme_font_size_override("font_size", font_size)
    add_child(label)
    return label

func _add_command(parent: Container, text_value: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(280, 38)
    button.pressed.connect(callback)
    parent.add_child(button)
    command_buttons.append(button)

func _on_attack() -> void:
    _enter_target_mode(-1)

func _on_skill(index: int) -> void:
    if manager.current_actor == null or index < 0 or index >= manager.skills.size():
        return
    var skill: BattleSkill = manager.skills[index]
    if skill.heals or skill.restores_sp:
        _show_result(manager.player_skill(index, 0))
        return
    _enter_target_mode(index)

func _enter_target_mode(skill_index: int) -> void:
    if not manager.waiting_for_player:
        return
    target_mode = true
    pending_skill_index = skill_index
    enemy_title_label.text = "CHOOSE TARGET"
    _refresh()

func _on_target_selected(index: int) -> void:
    if not target_mode:
        return
    var result := ""
    if pending_skill_index == -1:
        result = manager.player_attack(index)
    else:
        result = manager.player_skill(pending_skill_index, index)
    target_mode = false
    pending_skill_index = -1
    _show_result(result)

func _on_guard() -> void:
    target_mode = false
    pending_skill_index = -1
    _show_result(manager.player_guard())

func _on_skip() -> void:
    target_mode = false
    pending_skill_index = -1
    _show_result(manager.player_skip())

func _show_result(result: String) -> void:
    if result != "":
        log_label.text = result
    _refresh()

func _refresh() -> void:
    if manager == null or manager.current_actor == null:
        return

    var actor: BattleUnit = manager.current_actor
    active_name_label.text = actor.unit_name
    hp_label.text = "HP  %d / %d" % [actor.hp, actor.max_hp]
    sp_label.text = "SP  %d / %d" % [actor.sp, actor.max_sp]

    turn_label.text = "ROUND %d  •  TURN %d  •  %s" % [
        manager.round_number,
        manager.turn_number,
        "YOUR TURN" if manager.waiting_for_player else "ENEMY TURN"
    ]

    var order := manager.get_turn_order_names()
    turn_order_label.text = "TURN ORDER  →  " + "  →  ".join(order)

    var can_act := manager.waiting_for_player and not manager.battle_over
    for button in command_buttons:
        button.disabled = not can_act

    for i in skill_buttons.size():
        if i >= manager.skills.size():
            continue
        var skill: BattleSkill = manager.skills[i]
        skill_buttons[i].text = "%s   [%d SP]" % [skill.skill_name, skill.sp_cost]
        skill_buttons[i].tooltip_text = skill.description
        skill_buttons[i].disabled = not can_act or actor.sp < manager._get_effective_sp_cost(skill, actor)

    for i in enemy_buttons.size():
        if i >= manager.enemies.size():
            continue
        var foe: BattleEnemy = manager.enemies[i]
        if not foe.is_alive():
            enemy_buttons[i].text = "%s   —   DEFEATED" % foe.unit_name
            enemy_buttons[i].disabled = true
        else:
            enemy_buttons[i].text = "%s   —   HP %d / %d" % [foe.unit_name, foe.hp, foe.max_hp]
            enemy_buttons[i].disabled = not can_act or not target_mode

    enemy_title_label.text = "CHOOSE TARGET" if target_mode else "ENEMIES"

func _on_battle_finished(victory: bool) -> void:
    target_mode = false
    if victory:
        victory_panel.visible = true
        for button in command_buttons:
            button.disabled = true
        for button in skill_buttons:
            button.disabled = true
        for button in enemy_buttons:
            button.disabled = true
    else:
        get_tree().change_scene_to_file("res://scenes/world/World.tscn")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and target_mode:
        target_mode = false
        pending_skill_index = -1
        _refresh()
    elif event is InputEventKey and event.pressed and event.keycode == KEY_ENTER and victory_panel.visible:
        get_tree().change_scene_to_file("res://scenes/world/World.tscn")
