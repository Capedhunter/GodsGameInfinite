extends Sprite2D

## 8-direction protagonist animation controller.
## Rows: down, down-right, right, up-right, up, up-left, left, down-left.
## Columns: four idle/walk frames.

@export var idle_fps: float = 2.0
@export var walk_fps: float = 9.0
@export var walk_bob_amount: float = 1.0

var direction := Vector2.DOWN
var is_moving := false
var _frame_timer := 0.0
var _frame_index := 0
var _direction_row := 0
var _base_position := Vector2.ZERO

func _ready() -> void:
    hframes = 4
    vframes = 8
    frame = 0
    _base_position = position
    _update_frame()

func set_direction(input_direction: Vector2) -> void:
    if input_direction.length_squared() <= 0.001:
        return

    direction = input_direction.normalized()
    var angle := direction.angle()

    # Convert Godot's screen-space angle into our clockwise 8-row layout.
    _direction_row = posmod(int(round((PI / 2.0 - angle) / (PI / 4.0))), 8)
    _update_frame()

func set_moving(value: bool) -> void:
    if is_moving == value:
        return

    is_moving = value
    _frame_timer = 0.0
    _frame_index = 0
    _update_frame()

func _process(delta: float) -> void:
    var fps := walk_fps if is_moving else idle_fps
    _frame_timer += delta

    if _frame_timer >= 1.0 / max(fps, 0.01):
        _frame_timer = 0.0
        _frame_index = (_frame_index + 1) % 4
        _update_frame()

    var bob := 0.0
    if is_moving:
        bob = sin(Time.get_ticks_msec() * 0.001 * walk_fps * PI) * walk_bob_amount
    position.y = _base_position.y + bob

func _update_frame() -> void:
    frame = _direction_row * 4 + _frame_index
