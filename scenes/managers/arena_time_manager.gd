extends Node

@export var end_screen_scene: PackedScene
@onready var timer = $Timer

signal arena_difficulty_increased(arena_difficulty: int)
signal boss_enemy_spawn

const DIFFICULTY_INTERVAL = 5

var arena_difficulty = 0

func _ready():
	timer.timeout.connect(on_timer_timeout)
	
func _process(delta):
	var next_time_target = timer.wait_time - ((arena_difficulty + 1) * DIFFICULTY_INTERVAL)
	if timer.time_left <= next_time_target:
		arena_difficulty += 1
		arena_difficulty_increased.emit(arena_difficulty)

func get_time_ellapsed():
	return timer.wait_time - timer.time_left

func on_timer_timeout():
	MusicPlayer.stop()
	BossMusicPlayer.play()
	boss_enemy_spawn.emit()
