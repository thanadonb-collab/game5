@tool
extends Node3D

# Spikes that pop out of the ground on a timer.
# Watch the warning shake, then run across while they are down!

@export var size := Vector2(2, 2):
	set(v):
		size = v
		_rebuild()
@export var up_time := 1.2
@export var down_time := 1.6
## Offset (seconds) so several traps can be out of sync
@export var time_offset := 0.0
## Always out (static spikes)
@export var always_up := false

const HIDDEN_Y := -0.7
var _spikes : Node3D
var _hazard : Area3D
var _timer := 0.0
var _is_up := false

static var _metal : StandardMaterial3D
static var _plate : StandardMaterial3D

func _ready():
	_rebuild()
	if Engine.is_editor_hint():
		return
	_timer = time_offset
	_set_up(always_up, false)

func _rebuild():
	if not is_inside_tree():
		return
	for c in get_children():
		if str(c.name).begins_with("_"):
			remove_child(c)
			c.queue_free()
	if _metal == null:
		_metal = StandardMaterial3D.new()
		_metal.albedo_color = Color(0.82, 0.84, 0.9)
		_metal.metallic = 0.6
		_metal.roughness = 0.35
		_plate = StandardMaterial3D.new()
		_plate.albedo_color = Color(0.35, 0.3, 0.32)

	var plate := MeshInstance3D.new()
	plate.name = "_Plate"
	var pm := BoxMesh.new()
	pm.size = Vector3(size.x, 0.1, size.y)
	plate.mesh = pm
	plate.material_override = _plate
	plate.position.y = 0.05
	add_child(plate)

	_spikes = Node3D.new()
	_spikes.name = "_Spikes"
	add_child(_spikes)
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.18
	cone.height = 0.7
	cone.radial_segments = 6
	cone.rings = 1
	var nx = max(1, int(size.x / 0.5))
	var nz = max(1, int(size.y / 0.5))
	for ix in nx:
		for iz in nz:
			var s := MeshInstance3D.new()
			s.mesh = cone
			s.material_override = _metal
			s.position = Vector3((ix + 0.5) * size.x / nx - size.x / 2, 0.35, (iz + 0.5) * size.y / nz - size.y / 2)
			_spikes.add_child(s)

	_hazard = Area3D.new()
	_hazard.name = "_Hazard"
	_hazard.set_script(preload("res://Scripts/Traps/Hazard.gd"))
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(size.x - 0.1, 0.6, size.y - 0.1)
	cs.shape = box
	cs.position.y = 0.3
	_hazard.add_child(cs)
	add_child(_hazard)

func _set_up(up: bool, animate := true):
	_is_up = up
	_hazard.active = up
	var y = 0.0 if up else HIDDEN_Y
	if animate:
		var t := create_tween()
		t.tween_property(_spikes, "position:y", y, 0.08 if up else 0.3)
		if up and _player_near():
			AudioManager.spike_sfx.play()
	else:
		_spikes.position.y = y

func _player_near() -> bool:
	var p = get_tree().get_first_node_in_group("Player")
	return p != null and p.global_position.distance_to(global_position) < 12.0

func _process(delta):
	if Engine.is_editor_hint() or always_up:
		return
	_timer += delta
	if _is_up:
		if _timer >= up_time:
			_timer = 0.0
			_set_up(false)
	else:
		# Warning: spikes peek out & shake just before popping up
		if _timer >= down_time - 0.45:
			_spikes.position.y = HIDDEN_Y + 0.3 + sin(_timer * 60.0) * 0.04
		if _timer >= down_time:
			_timer = 0.0
			_set_up(true)
