extends Node2D

@export var MaxDistance: int = 0
@export var Damage: float = 0

@onready var Area: Area2D = $Hitbox
const SPEED: int = 1000
var distance: float = 0

func _physics_process(delta):
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	distance += SPEED * delta
	check_collision()
	if distance > MaxDistance:
		free()
	
func check_collision():
	var bodies: Array[Node2D] = $Hitbox.get_overlapping_bodies()
	
	if bodies.size() > 0:
		queue_free()
		for body in bodies:
			if body.has_method("take_damage"):
				body.take_damage(Damage)
	
