extends CanvasLayer

# In-game HUD: coins, lives, timer, messages, pause and game-over panels.

@onready var coins_label : Label = %CoinsLabel
@onready var hearts : HBoxContainer = %Hearts
@onready var time_label : Label = %TimeLabel
@onready var title_box : Control = %TitleBox
@onready var title_label : Label = %TitleLabel
@onready var subtitle_label : Label = %SubtitleLabel
@onready var message_label : Label = %MessageLabel
@onready var hint_label : Label = %HintLabel
@onready var pause_panel : Control = %PausePanel
@onready var gameover_panel : Control = %GameOverPanel

var _msg_tween : Tween

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.message.connect(show_message)
	pause_panel.visible = false
	gameover_panel.visible = false
	message_label.modulate.a = 0.0
	%ResumeButton.pressed.connect(toggle_pause)
	%RestartButton.pressed.connect(GameManager.restart_level)
	%MenuButton.pressed.connect(GameManager.go_to_menu)
	%RetryButton.pressed.connect(GameManager.restart_level)
	%GOMenuButton.pressed.connect(GameManager.go_to_menu)
	_on_coins_changed(GameManager.score, GameManager.total_coins)
	_on_lives_changed(GameManager.lives)

func _process(_delta):
	time_label.text = GameManager.format_time(GameManager.level_time)
	hint_label.visible = Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED and not get_tree().paused and not gameover_panel.visible

func _unhandled_input(event):
	if event.is_action_pressed("pause") and not gameover_panel.visible:
		toggle_pause()

func toggle_pause():
	var p = not get_tree().paused
	get_tree().paused = p
	pause_panel.visible = p
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if p else Input.MOUSE_MODE_CAPTURED)

func _on_coins_changed(collected: int, total: int):
	coins_label.text = "%d / %d" % [collected, total]
	var t := create_tween()
	coins_label.pivot_offset = coins_label.size / 2
	t.tween_property(coins_label, "scale", Vector2(1.3, 1.3), 0.08)
	t.tween_property(coins_label, "scale", Vector2.ONE, 0.12)

func _on_lives_changed(lives: int):
	for i in hearts.get_child_count():
		var h : CanvasItem = hearts.get_child(i)
		h.modulate = Color(1, 1, 1, 1) if i < lives else Color(0.2, 0.2, 0.2, 0.5)

func _on_game_over():
	gameover_panel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func show_title(title: String, subtitle: String):
	title_label.text = title
	subtitle_label.text = subtitle
	title_box.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(title_box, "modulate:a", 1.0, 0.6)
	t.tween_interval(2.6)
	t.tween_property(title_box, "modulate:a", 0.0, 0.8)

func show_message(text: String):
	message_label.text = text
	if _msg_tween:
		_msg_tween.kill()
	_msg_tween = create_tween()
	message_label.modulate.a = 1.0
	_msg_tween.tween_interval(1.8)
	_msg_tween.tween_property(message_label, "modulate:a", 0.0, 0.6)
