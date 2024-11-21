extends Node2D

func _ready():
	%Smoke.material.set_shader_parameter("texture_offset", Vector2(randfn(0.0, 1.0), randfn(0.0, 1.0)))
	%AnimationPlayer.play("explosion")
	await %AnimationPlayer.animation_finished
	queue_free()

var damaged: bool = false
@export var Damage: float = 20.0

func _process(_delta):
	if damaged:
		return
	
	var bodies: Array[Node2D] = $Hitbox.get_overlapping_bodies()
	
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(Damage)
	
	damaged = bodies.size() != 0
