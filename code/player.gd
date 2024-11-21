class_name PlayerNode extends CharacterBody2D

signal player_died()

@export var MovementSpeed: float = 400
@export var health: float = 100.0

var MovementVector: Vector2 = Vector2(0, 0)
const MULTIPLIER: float = 6.0
const DAMAGE_RATE: float = 5.0

@onready var Fireball: PackedScene = preload("res://scenes/fireball.tscn")
@onready var TimerFireball: Timer = $FireballTimer
var fireBalls = 0

func _ready():
	change_fireballs(0)

func change_fireballs(amount: int = 1):
	fireBalls += amount
	if fireBalls == 0:
		TimerFireball.stop()
	else:
		TimerFireball.set_wait_time(1.0 / float(fireBalls))
		if TimerFireball.is_stopped():
			TimerFireball.start()

func _physics_process(delta):
	movement(delta)
	take_damage(delta)

func movement(delta: float):
	var mov = Input.get_vector("left", "right", "up", "down")
	MovementVector = MovementVector.lerp(mov.normalized(), delta * MULTIPLIER)
	velocity = MovementVector * MovementSpeed
	move_and_slide()

func take_damage(delta: float):
	var overlappingMobs: Array[Node2D] = $HurtBox.get_overlapping_bodies()
	health -= overlappingMobs.size() * DAMAGE_RATE * delta
	if health <= 0.0:
		player_died.emit()


func _on_timer_timeout():
	var overlappingMobs: Array[Node2D] = $DetectionBox.get_overlapping_bodies()
	if overlappingMobs.size() > 0:
		var ball = Fireball.instantiate()
		ball.global_position = global_position
		ball.MaxDistance = 1000
		ball.Damage = 15
		get_parent().add_child(ball)
		ball.look_at(overlappingMobs[0].global_position)
