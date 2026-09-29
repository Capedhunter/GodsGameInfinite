extends Sprite2D

## Reusable 8-direction character animator.
## Uses a 4-frame walk/idle sheet. Direction state is kept separate so
## clean directional art can be swapped in later without changing movement code.

@export var idle_fps: float = 2.0
@export var walk_fps: float = 8.0
@export var idle_bob_amount: float = 1.5
@export var walk_bob_amount: float = 2.0

var direction := Vector2.DOWN
var is_moving := false
var _frame_timer := 0.0
var _frame_index := 0
var _base_position := Vector2.ZERO

func _ready() -> void:
    hframes = 4
    vframes = 1
    frame = 0
    _base_position = position

func set_direction(input_direction: Vector2) -> void:
    if input_direction.length_squared() <= 0.001:
        return

    direction = input_direction.normalized()

    # Current character sheets are front-facing. Horizontal facing is still
    # represented correctly; diagonal/up states are preserved for future art.
    if abs(direction.x) > 0.05:
        flip_h = direction.x < 0.0

func set_moving(value: bool) -> void:
    if is_moving == value:
        return
    is_moving = value
    _frame_timer = 0.0
    _frame_index = 0
    frame = 0

func _process(delta: float) -> void:
    var fps := walk_fps if is_moving else idle_fps
    _frame_timer += delta

    if _frame_timer >= 1.0 / max(fps, 0.01):
        _frame_timer = 0.0
        _frame_index = (_frame_index + 1) % 4
        frame = _frame_index

    var bob_amount := walk_bob_amount if is_moving else idle_bob_amount
    var bob_speed := walk_fps if is_moving else idle_fps
    position.y = _base_position.y + sin(Time.get_ticks_msec() * 0.001 * bob_speed * PI) * bob_amount
