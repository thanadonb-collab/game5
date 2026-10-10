extends Node3D

# Title screen with a slowly orbiting camera around a small diorama.

@export var victory_screen := false

@onready var pivot : Node3D = $CameraPivot
@onready var anim : AnimationPlayer = get_node_or_null("Hero/AnimationPlayer")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	if anim:
		anim.play("Victory" if victory_screen else "Idle")
	%StartButton.pressed.connect(_on_start)
	%StartButton.grab_focus()
	if has_node("%HowButton"):
		%HowButton.pressed.connect(func(): %HowPanel.visible = not %HowPanel.visible)
	if has_node("%MenuButton"):
		%MenuButton.pressed.connect(GameManager.go_to_menu)
	if has_node("%QuitButton"):
		%QuitButton.visible = OS.get_name() != "Web"
		%QuitButton.pressed.connect(func(): get_tree().quit())
	if victory_screen and has_node("%StatsLabel"):
		%StatsLabel.text = "เหรียญทั้งหมด: %d    เวลา: %s    พลาดไป: %d ครั้ง" % [
			GameManager.total_score, GameManager.format_time(GameManager.total_time), GameManager.deaths]

func _process(delta):
	pivot.rotate_y(delta * 0.15)

func _on_start():
	GameManager.start_game()
