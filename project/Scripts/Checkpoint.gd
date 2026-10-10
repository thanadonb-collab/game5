extends Area3D

# Checkpoint flag. Touch it to save your respawn position.

var activated := false
@onready var flag : Node3D = $Flag

func _ready():
	body_entered.connect(_on_body_entered)
	flag.scale = Vector3(1, 0.4, 1)
	_tint(Color(0.6, 0.6, 0.6))

func _on_body_entered(body):
	if activated or not body.is_in_group("Player"):
		return
	activated = true
	body.set_checkpoint(global_position + Vector3.UP * 0.5)
	AudioManager.checkpoint_sfx.play()
	GameManager.message.emit("Checkpoint!")
	_tint(Color(1, 1, 1))
	var t := create_tween()
	t.tween_property(flag, "scale", Vector3(1.2, 1.3, 1.2), 0.2).set_trans(Tween.TRANS_BACK)
	t.tween_property(flag, "scale", Vector3.ONE, 0.2)

func _tint(c: Color):
	for m in flag.find_children("*", "MeshInstance3D", true, false):
		var mat := StandardMaterial3D.new()
		var src = m.get_active_material(0)
		if src is StandardMaterial3D:
			mat = src.duplicate()
		mat.albedo_color = c
		m.material_override = mat
