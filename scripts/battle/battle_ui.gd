extends Control

var manager: BattleManager
var log_label: Label
var hp_label: Label
var sp_label: Label
var enemy_hp_label: Label
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
    title.position = Vector2(80, 50)
    title.add_theme_font_size_override("font_size", 34)
    add_child(title)

    var enemy_title := Label.new()
    enemy_title.text = "VOID ECHO"
    enemy_title.position = Vector2(850, 120)
    enemy_title.add_theme_font_size_override("font_size", 28)
    add_child(enemy_title)

    enemy_hp_label = _label(Vector2(850, 165), 20)
    hp_label = _label(Vector2(80, 500), 22)
    sp_label = _label(Vector2(80, 535), 22)

    log_label = _label(Vector2(430, 420), 18)
    log_label.size = Vector2(520, 130)
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    var actions := HBoxContainer.new()
    actions.position = Vector2(70, 590)
    actions.add_theme_constant_override("separation", 8)
    add_child(actions)

    _add_action(actions, "Attack", _on_attack)
    _add_action(actions, "Guard", _on_guard)
    for i in 4:
        var button := Button.new()
        button.custom_minimum_size = Vector2(135, 44)
        button.pressed.connect(_on_skill.bind(i))
        actions.add_child(button)
        skill_buttons.append(button)

    victory_panel = PanelContainer.new()
    victory_panel.position = Vector2(430, 250)
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
    button.custom_minimum_size = Vector2(110, 44)
    button.pressed.connect(callback)
    parent.add_child(button)
    action_buttons.append(button)

func _on_attack() -> void:
    _show_result(manager.player_attack())

func _on_guard() -> void:
    _show_result(manager.player_guard())

func _on_skill(index: int) -> void:
    _show_result(manager.player_skill(index))

func _show_result(result: String) -> void:
    if result != "":
        log_label.text = result
    _refresh()

func _refresh() -> void:
    if manager.player == null:
        return
    hp_label.text = "PROTAGONIST  HP %d / %d" % [manager.player.hp, manager.player.max_hp]
    sp_label.text = "SP %d / %d" % [manager.player.sp, manager.player.max_sp]
    enemy_hp_label.text = "HP %d / %d" % [manager.enemy.hp, manager.enemy.max_hp]
    for i in skill_buttons.size():
        var skill: BattleSkill = manager.skills[i]
        skill_buttons[i].text = "%s [%d SP]" % [skill.skill_name, skill.sp_cost]
        skill_buttons[i].tooltip_text = skill.description
        skill_buttons[i].disabled = manager.battle_over or manager.player.sp < skill.sp_cost
    for button in action_buttons:
        button.disabled = manager.battle_over

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
