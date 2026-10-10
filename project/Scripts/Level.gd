extends Node3D

# Root script for every level scene.

@export var level_index := 0
@export var level_name := "Level"
@export_multiline var level_subtitle := ""

func _ready():
	GameManager.register_level(level_index)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var hud = get_node_or_null("HUD")
	if hud:
		hud.show_title(level_name, level_subtitle)
