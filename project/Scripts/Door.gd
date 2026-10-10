@tool
extends Node3D

# Exit door. Locked (red) until every coin in the level is collected,
# then it swings open (green) and walking through finishes the level.

var _door_pivot : Node3D
var _light : OmniLight3D
var _label : Label3D
var _barrier : CollisionShape3D
var _gem : MeshInstance3D
var _gem_mat : StandardMaterial3D
var _opened := false
var _finished := false

const LOCKED := Color(1.0, 0.3, 0.25)
const OPEN := Color(0.3, 1.0, 0.45)

func _ready():
	_build()
	if Engine.is_editor_hint():
		return
	GameManager.door_unlocked.connect(open_door)
	GameManager.coins_changed.connect(_on_coins_changed)

func _mat(c: Color, emission := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.85
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emission
	return m

func _box(parent: Node, size: Vector3, pos: Vector3, mat: Material, collide := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = size
		cs.shape = sh
		body.add_child(cs)
		body.position = pos
		parent.add_child(body)
	return mi

func _build():
	for c in get_children():
		if str(c.name).begins_with("_"):
			remove_child(c)
			c.queue_free()
	var root := Node3D.new()
	root.name = "_Root"
	add_child(root)

	var stone := _mat(Color(0.62, 0.6, 0.66))
	var dark := _mat(Color(0.4, 0.38, 0.44))
	var wood := _mat(Color(0.55, 0.34, 0.2))
	var gold := _mat(Color(1.0, 0.8, 0.25), 0.4)

	# Frame: two pillars + lintel + steps
	_box(root, Vector3(0.8, 4.0, 0.8), Vector3(-1.6, 2.0, 0), stone)
	_box(root, Vector3(0.8, 4.0, 0.8), Vector3(1.6, 2.0, 0), stone)
	_box(root, Vector3(4.2, 0.8, 1.0), Vector3(0, 4.3, 0), dark)
	_box(root, Vector3(1.0, 0.3, 1.2), Vector3(-1.6, 0.15, 0), dark, false)
	_box(root, Vector3(1.0, 0.3, 1.2), Vector3(1.6, 0.15, 0), dark, false)
	# Gem on top (shows lock state)
	_gem_mat = _mat(LOCKED, 2.0)
	_gem = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.35
	sm.height = 0.7
	sm.radial_segments = 8
	sm.rings = 4
	_gem.mesh = sm
	_gem.material_override = _gem_mat
	_gem.position = Vector3(0, 5.1, 0)
	root.add_child(_gem)

	# Door leaf hinged on the left pillar
	_door_pivot = Node3D.new()
	_door_pivot.position = Vector3(-1.2, 0, 0)
	root.add_child(_door_pivot)
	var leaf := _box(_door_pivot, Vector3(2.4, 3.9, 0.25), Vector3(1.2, 1.95, 0), wood, false)
	_box(leaf, Vector3(0.25, 0.25, 0.1), Vector3(0.8, 0, 0.18), gold, false)
	_box(leaf, Vector3(2.4, 0.15, 0.3), Vector3(0, 1.0, 0), dark, false)
	_box(leaf, Vector3(2.4, 0.15, 0.3), Vector3(0, -1.0, 0), dark, false)

	# Invisible barrier blocks the doorway while locked
	var barrier_body := StaticBody3D.new()
	barrier_body.name = "Barrier"
	_barrier = CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(2.4, 4.0, 0.6)
	_barrier.shape = bs
	_barrier.position = Vector3(0, 2.0, 0)
	barrier_body.add_child(_barrier)
	root.add_child(barrier_body)

	_light = OmniLight3D.new()
	_light.light_color = LOCKED
	_light.light_energy = 2.0
	_light.omni_range = 6.0
	_light.position = Vector3(0, 3.0, 1.2)
	root.add_child(_light)

	_label = Label3D.new()
	_label.text = "LOCKED"
	_label.font_size = 64
	_label.outline_size = 16
	_label.pixel_size = 0.01
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.position = Vector3(0, 6.1, 0)
	_label.modulate = LOCKED
	var font = load("res://Assets/Fonts/GameFont.tres")
	if font:
		_label.font = font
	root.add_child(_label)

	# Finish trigger (in the doorway)
	var goal := Area3D.new()
	var gcs := CollisionShape3D.new()
	var gsh := BoxShape3D.new()
	gsh.size = Vector3(2.4, 3.0, 1.6)
	gcs.shape = gsh
	gcs.position = Vector3(0, 1.5, 0)
	goal.add_child(gcs)
	root.add_child(goal)
	if not Engine.is_editor_hint():
		goal.body_entered.connect(_on_goal_entered)

func _on_coins_changed(collected: int, total: int):
	if not _opened:
		_label.text = "LOCKED  %d / %d" % [collected, total]

func _process(delta):
	if _gem:
		_gem.rotate_y(delta * 1.5)

func open_door():
	if _opened:
		return
	_opened = true
	AudioManager.unlock_sfx.play()
	_barrier.set_deferred("disabled", true)
	_label.text = "OPEN!"
	_label.modulate = OPEN
	_light.light_color = OPEN
	_gem_mat.albedo_color = OPEN
	_gem_mat.emission = OPEN
	var t := create_tween()
	t.tween_property(_door_pivot, "rotation_degrees:y", 105.0, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_goal_entered(body):
	if not _opened or _finished or not body.is_in_group("Player"):
		return
	_finished = true
	body.victory(global_position)
	AudioManager.win_sfx.play()
	GameManager.message.emit("ผ่านด่านแล้ว!")
	GameManager.level_active = false
	await get_tree().create_timer(2.6).timeout
	GameManager.complete_level()
