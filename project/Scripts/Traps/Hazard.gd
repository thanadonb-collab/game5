extends Area3D

# Generic damaging area. While `active`, any player overlapping it takes damage
# (the player's invincibility frames stop it from hitting every frame).

@export var active := true
## Where the knockback comes from. If null, this area's position is used.
@export var knockback_origin : Node3D

func _ready():
	monitoring = true
	collision_mask = 1

func _physics_process(_delta):
	if not active:
		return
	for body in get_overlapping_bodies():
		if body.is_in_group("Player") and body.has_method("take_damage"):
			var origin = knockback_origin.global_position if knockback_origin else global_position
			body.take_damage(origin)
