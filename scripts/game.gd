extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var game_over_scene = $UI/GameOverScene
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea
@onready var laser_sound = $LaserSound
@onready var asteroid_destroyed_sound = $AsteroidDestroyedSound
@onready var player_die_sound = $PlayerDieSound


var asteroid_scene = preload("res://scenes/asteroid.tscn")
var game_running = false

var score:
	set(value):
		score = value
		hud.score = score
		
var lives:
	set(value):
		lives = value
		hud.init_lives(lives)

func _ready():
	game_over_scene.visible = false
	score = 0
	lives = 3
	player.connect("laser_shot", on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded",_on_asteroid_exploded)
	
	
func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
'''
	if !game_running:
		#TIMEOUT TO CLEAR PLAYER SPAWN AREA OF ASTEROIDS BEFORE SPAWNING PLAYER	
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		game_running = true
'''
func on_player_laser_shot(laser):
	laser_sound.play()
	lasers.call_deferred("add_child", laser)

func _on_asteroid_exploded(pos, size, points):
	asteroid_destroyed_sound.play()
	score += points
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass
	print(score)

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)
	
func _on_player_died():
	player_die_sound.play()
	lives -= 1
	player.global_position = player_spawn_pos.global_position
	if lives <= 0:
		game_over_scene.visible = true
	else:
		await get_tree().create_timer(0.1).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout			
		player.respawn(player_spawn_pos.global_position)

		
		
		
		
		
