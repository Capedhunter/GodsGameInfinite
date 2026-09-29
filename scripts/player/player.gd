extends CharacterBody2D

## 8-directional overworld player movement and animation.

@export var move_speed: float = 220.0

@onready var visual = $Visual

func _physics_process(_delta: float) -> void:
    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_vector * move_speed
    move_and_slide()

    var moving := input_vector.length_squared() > 0.001
    visual.set_moving(moving)

    if moving:
        visual.set_direction(input_vector)
