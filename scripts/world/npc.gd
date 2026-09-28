extends CharacterBody2D

## Reusable NPC controller with character-specific visual art and simple interaction.

@export var character_name: String = "NPC"
@export_multiline var dialogue: String = "Hello, traveler."
@export_file("*.svg") var character_art_path: String

var player_in_range := false
var dialogue_label: Label

func _ready() -> void:
    dialogue_label = Label.new()
    dialogue_label.visible = false
    dialogue_label.position = Vector2(-150, -155)
    dialogue_label.size = Vector2(300, 90)
    dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_label.add_theme_color_override("font_color", Color(0.96, 0.94, 1.0))
    dialogue_label.add_theme_color_override("font_outline_color", Color(0.06, 0.05, 0.09))
    dialogue_label.add_theme_constant_override("outline_size", 6)
    add_child(dialogue_label)

    if character_art_path != "":
        var texture := load(character_art_path) as Texture2D
        if texture:
            $CharacterSprite.texture = texture

    $InteractionArea.body_entered.connect(_on_body_entered)
    $InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        player_in_range = true

func _on_body_exited(body: Node2D) -> void:
    if body.name == "Player":
        player_in_range = false
        dialogue_label.visible = false

func _physics_process(_delta: float) -> void:
    if player_in_range and Input.is_action_just_pressed("interact"):
        dialogue_label.text = character_name + ": " + dialogue
        dialogue_label.visible = not dialogue_label.visible

func set_player_in_range(value: bool) -> void:
    player_in_range = value
