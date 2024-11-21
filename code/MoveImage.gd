extends Node2D

var NextPosition: Vector2 = Vector2(0,0)
var rng = RandomNumberGenerator.new()
var cycles = 0
@onready var CardImg = $CardImage

@export var MovementRange = 40
@export var Offset = Vector2(0, -MovementRange)
@export var CyclesUntilNewPosition = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cycles += 1
	if cycles > CyclesUntilNewPosition:
		var x = rng.randi_range(-MovementRange,MovementRange)
		var y = rng.randi_range(-MovementRange,MovementRange)
		NextPosition = Offset + Vector2(x, y)
		cycles = 0
	CardImg.position = CardImg.position.lerp(NextPosition, delta * 2.5)
