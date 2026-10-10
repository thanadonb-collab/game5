@tool
extends AnimatableBody3D

# Crumbling platform: shakes when the player lands on it, falls, then respawns.

@export var size := Vector3(3, 0.6, 3):
	set(v):
		size = v
		_rebuild()
@export_enum("grass", "meadow", "autumn", "moss", "stone", "wood", "danger", "crumble") var style := "crumble":
	set(v):
		style = v
		_rebuild()
@export var shake_time := 0.7
@export var respawn_time := 3.0

var _start := Vector3.ZERO
var _triggered := false
var _detector : Area3D

func _ready():
	_rebuild()
	if Engine.is_editor_hint():
		return
	_start = position
	_detector = Area3D.new()
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(size.x * 0.9, 0.4, size.z * 0.9)
	cs.shape = box
	cs.position.y = 0.25
	_detector.add_child(cs)
	add_child(_detector)
	_detector.body_entered.connect(_on_body_entered)

func _rebuild():
	if not is_inside_tree():
		return
	PlatformBuilder.clear(self)
	PlatformBuilder.build(self, size, style, false)

func _on_body_entered(body):
	if _triggered or not body.is_in_group("Player"):
		return
	_triggered = true
	var t := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var steps = int(shake_time / 0.05)
	for i in steps:
		t.tween_property(self, "position", _start + Vector3(randf_range(-0.06, 0.06), 0, randf_range(-0.06, 0.06)), 0.05)
	t.tween_property(self, "position", _start + Vector3.DOWN * 25.0, 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(func(): visible = false)
	t.tween_interval(respawn_time)
	t.tween_callback(_reset)

func _reset():
	position = _start
	visible = true
	_triggered = false
