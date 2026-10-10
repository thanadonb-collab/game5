@tool
extends AnimatableBody3D

# Platform that moves back and forth between its start position and start + move_offset.

@export var size := Vector3(3, 0.6, 3):
	set(v):
		size = v
		_rebuild()
@export_enum("grass", "meadow", "autumn", "moss", "stone", "wood", "danger", "crumble") var style := "wood":
	set(v):
		style = v
		_rebuild()
@export var round_shape := false:
	set(v):
		round_shape = v
		_rebuild()
@export var move_offset := Vector3(0, 0, -8)
@export var duration := 2.5
@export var pause_time := 0.6

var _start := Vector3.ZERO

func _ready():
	_rebuild()
	if Engine.is_editor_hint():
		return
	sync_to_physics = true
	_start = position
	var t := create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	t.tween_property(self, "position", _start + move_offset, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_interval(pause_time)
	t.tween_property(self, "position", _start, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_interval(pause_time)

func _rebuild():
	if not is_inside_tree():
		return
	PlatformBuilder.clear(self)
	PlatformBuilder.build(self, size, style, round_shape)
