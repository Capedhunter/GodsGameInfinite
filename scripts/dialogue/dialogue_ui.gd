extends CanvasLayer

var is_open := false

@onready var panel: PanelContainer = $DialoguePanel
@onready var portrait: TextureRect = $DialoguePanel/Margin/HBox/PortraitFrame/Portrait
@onready var name_label: Label = $DialoguePanel/Margin/HBox/TextColumn/Name
@onready var text_label: Label = $DialoguePanel/Margin/HBox/TextColumn/Text
@onready var hint_label: Label = $DialoguePanel/Margin/HBox/TextColumn/Hint

func _ready() -> void:
    add_to_group("dialogue_ui")
    panel.visible = false

func show_dialogue(character_name: String, dialogue: String, portrait_path: String = "") -> void:
    name_label.text = character_name
    text_label.text = dialogue
    hint_label.text = "E  •  Close"
    _set_portrait(portrait_path)
    panel.visible = true
    is_open = true

func close_dialogue() -> void:
    panel.visible = false
    is_open = false

func toggle_dialogue(character_name: String, dialogue: String, portrait_path: String = "") -> void:
    if is_open:
        close_dialogue()
    else:
        show_dialogue(character_name, dialogue, portrait_path)

func _set_portrait(path: String) -> void:
    portrait.texture = null
    if path == "":
        return
    var texture := load(path) as Texture2D
    if texture:
        portrait.texture = texture
