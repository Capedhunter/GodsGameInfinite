extends CanvasLayer

## Opening story sequence for God's Game: Infinite.
## Advances with E, Enter, Space, or a mouse click.

var lines := [
    ["", "What would you do if you knew the truth?"],
    ["UNKNOWN VOICE", "Would you want to know?"],
    ["UNKNOWN VOICE", "Humanity has always searched for an answer."],
    ["UNKNOWN VOICE", "Why are we here? Why do we suffer? Why do we die?"],
    ["UNKNOWN VOICE", "And whenever humanity could not find an answer... it created one."],
    ["UNKNOWN VOICE", "God."],
    ["", "CHAPTER 1 — VALENTIN"],
    ["", "Rain falls against the pavement. Cars pass. People move beneath umbrellas."],
    ["", "Everything looks ordinary. Almost painfully ordinary."],
    ["", "A young man walks alone through the crowd."],
    ["VALENTIN", "Interesting."],
    ["UNKNOWN NUMBER", "Do you believe in God?"],
    ["VALENTIN", "Which one?"],
    ["UNKNOWN NUMBER", "Good answer."],
    ["UNKNOWN NUMBER", "Then answer another question."],
    ["UNKNOWN NUMBER", "What if they believe in you?"],
    ["", "Valentin's phone goes black."],
    ["WOMAN", "Valentin."],
    ["", "He turns. Nobody is there."],
    ["WOMAN", "Valentin."],
    ["", "At the end of an alley, a figure stands in the rain."],
    ["", "Then it disappears."],
    ["VALENTIN", "Okay."],
    ["", "He walks into the alley."]
]

var index := 0
var active := true

@onready var name_label: Label = $Overlay/Dialogue/Name
@onready var text_label: Label = $Overlay/Dialogue/Text
@onready var prompt_label: Label = $Overlay/Dialogue/Prompt
@onready var chapter_label: Label = $Overlay/Chapter

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    var player := get_tree().get_first_node_in_group("player")
    if player:
        player.set_physics_process(false)
    _show_line()

func _unhandled_input(event: InputEvent) -> void:
    if not active:
        return
    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or event is InputEventMouseButton and event.pressed:
        get_viewport().set_input_as_handled()
        _advance()

func _advance() -> void:
    index += 1
    if index >= lines.size():
        _finish()
    else:
        _show_line()

func _show_line() -> void:
    var entry = lines[index]
    name_label.text = str(entry[0])
    text_label.text = str(entry[1])
    prompt_label.text = "E / Enter / Click  •  Continue"
    chapter_label.text = "GOD'S GAME: INFINITE" if index < 6 else "CHAPTER 1  •  VALENTIN"

func _finish() -> void:
    active = false
    var player := get_tree().get_first_node_in_group("player")
    if player:
        player.set_physics_process(true)
    queue_free()
