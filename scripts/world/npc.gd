extends CharacterBody2D

@export var character_name: String = "NPC"
@export_multiline var dialogue: String = "Hello, traveler."

var player_in_range := false
var dialogue_label: Label

func _ready() -> void:
    dialogue_label = Label.new()
    dialogue_label.visible = false
    dialogue_label.position = Vector2(-150, -95)
    dialogue_label.size = Vector2(300, 80)
    dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(dialogue_label)

func _physics_process(_delta: float) -> void:
    if player_in_range and Input.is_action_just_pressed("interact"):
        dialogue_label.text = character_name + ": " + dialogue
        dialogue_label.visible = not dialogue_label.visible

func set_player_in_range(value: bool) -> void:
    player_in_range = value
