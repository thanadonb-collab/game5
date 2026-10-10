class_name PlatformBuilder
extends RefCounted

# Builds low-poly platform visuals + collision from a size and a style.
# Used by Platform.gd, MovingPlatform.gd and FallingPlatform.gd so every
# platform in the game shares the same look.

const STYLES := {
	"grass":  {"top": Color(0.30, 0.56, 0.22), "side": Color(0.55, 0.38, 0.24)},
	"meadow": {"top": Color(0.38, 0.62, 0.24), "side": Color(0.62, 0.45, 0.30)},
	"autumn": {"top": Color(0.72, 0.40, 0.16), "side": Color(0.42, 0.30, 0.24)},
	"moss":   {"top": Color(0.35, 0.50, 0.30), "side": Color(0.36, 0.33, 0.36)},
	"stone":  {"top": Color(0.52, 0.52, 0.58), "side": Color(0.40, 0.40, 0.46)},
	"wood":   {"top": Color(0.74, 0.52, 0.30), "side": Color(0.52, 0.34, 0.20)},
	"danger": {"top": Color(0.90, 0.30, 0.25), "side": Color(0.45, 0.25, 0.22)},
	"crumble":{"top": Color(0.80, 0.68, 0.45), "side": Color(0.58, 0.45, 0.30)},
}

static var _materials := {}

static func material(color: Color) -> StandardMaterial3D:
	var key = color.to_html()
	if not _materials.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color = color
		m.roughness = 0.9
		_materials[key] = m
	return _materials[key]

# Creates the meshes and collision shape as children of `node`.
# Top surface of the platform is at local y = 0.
static func build(node: Node3D, size: Vector3, style: String, round_shape: bool, with_collision := true) -> void:
	var colors = STYLES.get(style, STYLES["grass"])
	var top_h = min(0.35, size.y * 0.4)

	var body := MeshInstance3D.new()
	body.name = "_Body"
	var top := MeshInstance3D.new()
	top.name = "_Top"
	if round_shape:
		var cm := CylinderMesh.new()
		cm.top_radius = size.x * 0.5
		cm.bottom_radius = size.x * 0.38
		cm.height = size.y
		cm.radial_segments = 10
		cm.rings = 1
		body.mesh = cm
		var tm := CylinderMesh.new()
		tm.top_radius = size.x * 0.5 + 0.08
		tm.bottom_radius = size.x * 0.5 + 0.08
		tm.height = top_h
		tm.radial_segments = 10
		tm.rings = 1
		top.mesh = tm
	else:
		var bm := BoxMesh.new()
		bm.size = Vector3(size.x * 0.96, size.y, size.z * 0.96)
		body.mesh = bm
		var tb := BoxMesh.new()
		tb.size = Vector3(size.x + 0.1, top_h, size.z + 0.1)
		top.mesh = tb
	body.position.y = -size.y * 0.5
	top.position.y = -top_h * 0.5 + 0.01
	body.material_override = material(colors["side"])
	top.material_override = material(colors["top"])
	node.add_child(body)
	node.add_child(top)

	if with_collision:
		var cs := CollisionShape3D.new()
		cs.name = "_Collision"
		if round_shape:
			var cyl := CylinderShape3D.new()
			cyl.radius = size.x * 0.5
			cyl.height = size.y
			cs.shape = cyl
		else:
			var box := BoxShape3D.new()
			box.size = size
			cs.shape = box
		cs.position.y = -size.y * 0.5
		node.add_child(cs)

static func clear(node: Node) -> void:
	for c in node.get_children():
		if str(c.name).begins_with("_"):
			node.remove_child(c)
			c.queue_free()
