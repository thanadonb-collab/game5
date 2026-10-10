extends Node

# ---------- GAME MANAGER (Autoload) ---------- #
# Keeps track of coins, lives, level progression and timing.

signal coins_changed(collected: int, total: int)
signal lives_changed(lives: int)
signal door_unlocked
signal game_over
signal message(text: String)

const LEVELS := [
	"res://Scenes/Levels/Level1.tscn",
	"res://Scenes/Levels/Level2.tscn",
]
const MENU_SCENE := "res://Scenes/UI/MainMenu.tscn"
const VICTORY_SCENE := "res://Scenes/UI/Victory.tscn"
const MAX_LIVES := 3

var score := 0            # coins collected in the current level
var total_coins := 0      # coins that exist in the current level
var total_score := 0      # coins collected over the whole run
var lives := MAX_LIVES
var current_level := 0
var level_time := 0.0
var total_time := 0.0
var deaths := 0
var door_open := false
var level_active := false

# ---------- FUNCTIONS ---------- #

func _process(delta):
	show_mouse_cursor()
	if level_active:
		level_time += delta

# Making Cursor visible using "mouse_visible" key which is assigned in Project Settings > Input Map
func show_mouse_cursor():
	if Input.is_action_just_pressed("mouse_visible"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func start_game():
	total_score = 0
	total_time = 0.0
	deaths = 0
	load_level(0)

func load_level(index: int):
	current_level = index
	level_active = false
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", LEVELS[index])

func restart_level():
	load_level(current_level)

func go_to_menu():
	level_active = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().call_deferred("change_scene_to_file", MENU_SCENE)

# Called by Level.gd when a level scene becomes ready
func register_level(index: int):
	current_level = index
	score = 0
	lives = MAX_LIVES
	door_open = false
	level_time = 0.0
	level_active = true
	total_coins = get_tree().get_nodes_in_group("Coin").size()
	coins_changed.emit(score, total_coins)
	lives_changed.emit(lives)

func add_score():
	score += 1
	coins_changed.emit(score, total_coins)
	if score >= total_coins and not door_open:
		door_open = true
		door_unlocked.emit()
		message.emit("เก็บเหรียญครบแล้ว! ประตูเปิดแล้ว")

func coins_left() -> int:
	return max(total_coins - score, 0)

# Returns true when the player has no lives left
func lose_life() -> bool:
	lives -= 1
	deaths += 1
	lives_changed.emit(lives)
	return lives <= 0

func trigger_game_over():
	level_active = false
	game_over.emit()

func complete_level():
	level_active = false
	total_score += score
	total_time += level_time
	if current_level + 1 < LEVELS.size():
		load_level(current_level + 1)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().call_deferred("change_scene_to_file", VICTORY_SCENE)

func format_time(t: float) -> String:
	return "%02d:%02d" % [int(t) / 60, int(t) % 60]
