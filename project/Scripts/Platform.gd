@tool
extends StaticBody3D

# A static low-poly platform. Change size / style in the inspector.
# The top surface sits at this node's origin (y = 0).

@export var size := Vector3(6, 2, 6):
	set(v):
		size = v
		_rebuild()
@export_enum("grass", "meadow", "autumn", "moss", "stone", "wood", "danger", "crumble") var style := "grass":
	set(v):
		style = v
		_rebuild()
@export var round_shape := false:
	set(v):
		round_shape = v
		_rebuild()

func _ready():
	_rebuild()

func _rebuild():
	if not is_inside_tree():
		return
	PlatformBuilder.clear(self)
	PlatformBuilder.build(self, size, style, round_shape)
