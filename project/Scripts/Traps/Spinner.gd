@tool
extends Node3D

# A rotating log/bar that sweeps across a platform. Jump over it!

@export var arm_length := 6.0:
	set(v):
		arm_length = v
		_rebuild()
@export var speed_degrees := 90.0
@export var double_arm := false:
	set(v):
		double_arm = v
		_rebuild()
@export var arm_height := 0.45

var _pivot : Node3D

func _ready():
	_rebuild()

func _rebuild():
	if not is_inside_tree():
		return
	for c in get_children():
		if str(c.name).begins_with("_"):
			remove_child(c)
			c.queue_free()

	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.55, 0.33, 0.18)
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.85, 0.22, 0.2)

	# Centre post
	var post := MeshInstance3D.new()
	post.name = "_Post"
	var pm := CylinderMesh.new()
	pm.top_radius = 0.35
	pm.bottom_radius = 0.45
	pm.height = 1.2
	pm.radial_segments = 8
	post.mesh = pm
	post.material_override = red
	post.position.y = 0.6
	add_child(post)
	var post_body := StaticBody3D.new()
	post_body.name = "_PostBody"
	var pcs := CollisionShape3D.new()
	var pshape := CylinderShape3D.new()
	pshape.radius = 0.4
	pshape.height = 1.2
	pcs.shape = pshape
	pcs.position.y = 0.6
	post_body.add_child(pcs)
	add_child(post_body)

	_pivot = Node3D.new()
	_pivot.name = "_Pivot"
	_pivot.position.y = arm_height
	add_child(_pivot)

	var arm_mesh := CylinderMesh.new()
	arm_mesh.top_radius = 0.22
	arm_mesh.bottom_radius = 0.22
	arm_mesh.height = arm_length
	arm_mesh.radial_segments = 8
	var count = 2 if double_arm else 1
	for i in count:
		var arm := MeshInstance3D.new()
		arm.mesh = arm_mesh
		arm.material_override = wood
		arm.rotation_degrees = Vector3(0, 90 * i, 90)
		_pivot.add_child(arm)

		var hz := Area3D.new()
		hz.set_script(preload("res://Scripts/Traps/Hazard.gd"))
		hz.knockback_origin = self
		var cs := CollisionShape3D.new()
		var cap := CapsuleShape3D.new()
		cap.radius = 0.3
		cap.height = arm_length
		cs.shape = cap
		cs.rotation_degrees = Vector3(0, 90 * i, 90)
		hz.add_child(cs)
		_pivot.add_child(hz)

func _physics_process(delta):
	if _pivot:
		_pivot.rotate_y(deg_to_rad(speed_degrees) * delta)
