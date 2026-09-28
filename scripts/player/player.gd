extends CharacterBody2D

## Basic 8-directional player movement for the overworld.

@export var move_speed: float = 220.0

func _physics_process(_delta: float) -> void:
    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_vector * move_speed
    move_and_slide()
