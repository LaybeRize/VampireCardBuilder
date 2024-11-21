extends Node2D

@onready var Map: TileMap = $WorldMap
@onready var Player: CharacterBody2D = $Player
@onready var Enemy: PackedScene = preload("res://scenes/enemy.tscn")

var Spawner = RandomNumberGenerator.new()

const width: int = 200
const height: int = 200

const enemyDistance = 1100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_timer_timeout():
	spawn_creature()

func spawn_creature():
	var xMod: float = randf_range(-1, 1) * 100
	var yMod: float = randf_range(-1, 1) * 100
	var enemyPosition = Vector2(xMod,yMod).normalized() * enemyDistance
	var enemyRotation = 0
	while enemyRotation < 365:
		if tile_is_land(Map.local_to_map(Player.position + enemyPosition)):
			var newEnemy = Enemy.instantiate()
			newEnemy.Player = Player
			newEnemy.position = Player.position + enemyPosition
			$".".add_child(newEnemy)
			break
		enemyPosition = enemyPosition.rotated(deg_to_rad(1))
		enemyRotation += 1

func tile_is_land(tile: Vector2i) -> bool:
	return Map.get_cell_atlas_coords(0, tile) == Vector2i(1,7)

