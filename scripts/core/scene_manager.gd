extends Node

## Centralized scene transition service.

func change_scene(scene_path: String) -> void:
    if ResourceLoader.exists(scene_path):
        get_tree().change_scene_to_file(scene_path)
    else:
        push_error("Scene not found: " + scene_path)
