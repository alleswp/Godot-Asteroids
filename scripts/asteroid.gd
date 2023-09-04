class_name Asteroid extends Area2D

signal exploded(position, size, points)

var movement_vector := Vector2(0, -1)

enum AsteroidSize{LARGE, MEDIUM, SMALL}
@export var size := AsteroidSize.LARGE

var speed := 50.0

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

var points: int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.SMALL:
				return 25
			_:
				return 0
	
func _ready():
	rotation = randf_range(0, 2 * PI)
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50, 100)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_big4.png")
			cshape.set_deferred("shape", preload("res://resources/asteroid_collision_large.tres"))
		AsteroidSize.MEDIUM:
			speed = randf_range(100, 150)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_med2.png")
			cshape.set_deferred("shape", preload("res://resources/asteroid_collision_med.tres"))
		AsteroidSize.SMALL:
			speed = randf_range(100, 200)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_small2.png")
			cshape.set_deferred("shape", preload("res://resources/asteroid_collision_small.tres"))


func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var radius = cshape.shape.radius
	var screen_size = get_viewport_rect().size
	
	if global_position.y + radius < 0:
		global_position.y = screen_size.y + radius
	elif global_position.y - radius > screen_size.y:
		global_position.y = 0 - radius
		
	if global_position.x + radius < 0:
		global_position.x = screen_size.x + radius
	elif global_position.x - radius > screen_size.x:
		global_position.x = 0 - radius
		
func explode():
	emit_signal("exploded", global_position, size, points)
	#queue_free()
	call_deferred("free")

func _on_body_entered(body):
	if body is Player:
		var player = body
		player.die()
		
