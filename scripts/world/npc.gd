extends CharacterBody2D

## Reusable RPG NPC with animated character art, facing, and interaction prompt.

@export var character_name: String = "NPC"
@export_multiline var dialogue: String = "Hello, traveler."
@export_file("*.svg", "*.webp") var character_art_path: String
@export_file("*.svg", "*.webp") var portrait_path: String

var player_in_range := false
var player: Node2D

@onready var character_sprite = $CharacterSprite
@onready var interaction_prompt: Label = $InteractionPrompt

func _ready() -> void:
    $InteractionArea.body_entered.connect(_on_body_entered)
    $InteractionArea.body_exited.connect(_on_body_exited)

    if character_art_path != "":
        var texture := load(character_art_path) as Texture2D
        if texture:
            character_sprite.texture = texture

    character_sprite.set_moving(false)
    interaction_prompt.visible = false

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        player_in_range = true
        player = body
        interaction_prompt.visible = true
        _face_player()

func _on_body_exited(body: Node2D) -> void:
    if body == player:
        player_in_range = false
        player = null
        interaction_prompt.visible = false
        var dialogue_ui := get_tree().get_first_node_in_group("dialogue_ui")
        if dialogue_ui and dialogue_ui.is_open:
            dialogue_ui.close_dialogue()

func _physics_process(_delta: float) -> void:
    if player_in_range and is_instance_valid(player):
        _face_player()

    if player_in_range and Input.is_action_just_pressed("interact"):
        var dialogue_ui := get_tree().get_first_node_in_group("dialogue_ui")
        if dialogue_ui:
            dialogue_ui.toggle_dialogue(character_name, dialogue, portrait_path)

func _face_player() -> void:
    var to_player := player.global_position - global_position
    if to_player.length_squared() > 0.001:
        character_sprite.set_direction(to_player)

func set_player_in_range(value: bool) -> void:
    player_in_range = value
    interaction_prompt.visible = value
