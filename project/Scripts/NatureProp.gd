@tool
extends Node3D

# Places ONE mesh from a multi-mesh nature pack .glb (Quaternius Ultimate
# Stylized Nature Pack from poly.pizza). The mesh is re-centred so this
# node's origin sits at the bottom-centre of the model.

@export_file("*.glb") var source := "res://Assets/Models/Nature/Trees.glb":
	set(v):
		source = v
		_rebuild()
@export var mesh_name := "NormalTree_1":
	set(v):
		mesh_name = v
		_rebuild()
## Adds a cylinder collider (for trees / rocks the player should not walk through)
@export var collision_radius := 0.0:
	set(v):
		collision_radius = v
		_rebuild()
@export var collision_height := 3.0

static var _cache := {}

func _ready():
	_rebuild()

static func _find_meshes(n: Node, xf: Transform3D, out: Dictionary):
	var t := xf
	if n is Node3D:
		t = xf * n.transform
	if n is MeshInstance3D and n.mesh:
		out[str(n.name)] = [n.mesh, t]
	for c in n.get_children():
		_find_meshes(c, t, out)

static func get_mesh_data(path: String) -> Dictionary:
	if not _cache.has(path):
		var data := {}
		var scene = load(path)
		if scene:
			var inst = scene.instantiate()
			_find_meshes(inst, Transform3D.IDENTITY, data)
			inst.free()
		_cache[path] = data
	return _cache[path]

func _rebuild():
	if not is_inside_tree():
		return
	for c in get_children():
		if str(c.name).begins_with("_"):
			remove_child(c)
			c.queue_free()
	var data = get_mesh_data(source)
	if not data.has(mesh_name):
		return
	var mesh : Mesh = data[mesh_name][0]
	var xf : Transform3D = data[mesh_name][1]
	var aabb : AABB = xf * mesh.get_aabb()
	var mi := MeshInstance3D.new()
	mi.name = "_Mesh"
	mi.mesh = mesh
	var centre := aabb.position + aabb.size * 0.5
	xf.origin -= Vector3(centre.x, aabb.position.y, centre.z)
	mi.transform = xf
	add_child(mi)

	if collision_radius > 0.0:
		var body := StaticBody3D.new()
		body.name = "_Body"
		var cs := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = collision_radius
		shape.height = collision_height
		cs.shape = shape
		cs.position.y = collision_height * 0.5
		body.add_child(cs)
		add_child(body)
