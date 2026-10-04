extends CharacterBody2D

## Responsive 8-directional overworld player movement and animation.

@export var move_speed: float = 220.0
@export var acceleration: float = 1400.0
@export var deceleration: float = 1800.0

@onready var visual = $Visual

func _physics_process(delta: float) -> void:
    var dialogue_ui := get_tree().get_first_node_in_group("dialogue_ui")
    var dialogue_open := dialogue_ui != null and dialogue_ui.is_open

    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if dialogue_open:
        input_vector = Vector2.ZERO

    var target_velocity := input_vector * move_speed
    var rate := acceleration if input_vector.length_squared() > 0.001 else deceleration
    velocity = velocity.move_toward(target_velocity, rate * delta)
    move_and_slide()

    var moving := velocity.length_squared() > 100.0
    visual.set_moving(moving)

    # Only change facing when the player actually provides movement input.
    # This preserves the last direction while standing still.
    if input_vector.length_squared() > 0.001:
        visual.set_direction(input_vector)
