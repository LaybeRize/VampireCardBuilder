extends CharacterBody2D


const SPEED: float = 60

@export var Health: float = 100.0
@export var Player: PlayerNode

func _physics_process(_delta):
	var dir: Vector2 = to_local(Player.global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()

func take_damage(amount: float):
	Health -= amount
	if Health <= 0.0:
		queue_free()
