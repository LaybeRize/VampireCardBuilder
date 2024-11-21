class_name Card extends Node2D

signal mouse_entered(card: Card)
signal mouse_exited(card: Card)

@export var CardID: int = -1
@export var CardName: String = "Empty Card"
@export var CardDescription: String = "This is the description text"
@export var CardCost: int = 12
@export var CardImage: Node2D = null
@export var MouseOnMe: bool = false
@export var Y_Offset: int = 0
@export var Played: bool = false
@export var CanBePlayed: bool = true


var PositionWhileInHand: Vector2 = Vector2(0,0)
var RotationWhileInHand: float = 0
var MousePosition: Vector2 = Vector2(0,0)

@onready var CostLbl: Label = $CostDisplay/CardCostLabel
@onready var CardNameLbl: Label = $CardName/CardNameLabel
@onready var CardTextLbl: RichTextLabel = $CardText/CardTextLabel
@onready var BaseSprite: Sprite2D = $BaseCardSprite

const StandardScale: float = 0.6
const HoveredScale: float = 0.65
const HoveredOffset: Vector2 = Vector2(0, -60)
const FOLLOW_SPEED = 4.0
const MOUSE_FOLLOW_SPEED = 17.0

var Destination: Vector2 = Vector2(0,0)
var DestinedRotation: float = 0
var DestinedSize: Vector2 = Vector2(StandardScale, StandardScale)
var CurrentFollowSpeed = FOLLOW_SPEED
var FollowMouse: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if CardImage != null:
		$".".remove_child($CardImage)
		$".".add_child(CardImage)
	position.y += Y_Offset
	set_scale(Vector2(StandardScale, StandardScale))
	CostLbl.set_text(str(CardCost))
	CardNameLbl.set_text(CardName)
	CardTextLbl.bbcode_enabled = true
	CardTextLbl.set_text(CardDescription)

func set_new_card_cost(newCost: int):
	CardCost = newCost
	CostLbl.set_text(str(CardCost))

func set_new_position_and_rotation(_positon: Vector2, _rotation: float):
	PositionWhileInHand = _positon
	RotationWhileInHand = _rotation
	update_parameter()

func _on_card_area_mouse_entered():
	mouse_entered.emit(self)

func _on_card_area_mouse_exited():
	mouse_exited.emit(self)

func update_parameter():
	if FollowMouse:
		return
		
	if MouseOnMe:
		Destination = HoveredOffset + PositionWhileInHand
		DestinedSize = Vector2(HoveredScale, HoveredScale)
		BaseSprite.set_modulate(Color(0.6, 0.8, 1, 1))
	else:
		Destination = PositionWhileInHand
		DestinedSize = Vector2(StandardScale, StandardScale)
		BaseSprite.set_modulate(Color(1, 1, 1, 1))
	DestinedRotation = RotationWhileInHand

func update_destination() -> Vector2:
	var NewMousePosition = get_viewport().get_mouse_position()
	if FollowMouse:
		Destination += (NewMousePosition - MousePosition)
		DestinedSize = Vector2(HoveredScale, HoveredScale)
		BaseSprite.set_modulate(Color(0.65, 0.77, 1, 1))
		DestinedRotation = 0
		Played = Destination.y < -1850 and CanBePlayed
	else:
		update_parameter()
	return NewMousePosition
	
func update_mouse_clicked(_clicked: bool):
	FollowMouse = _clicked
	if _clicked:
		CurrentFollowSpeed = MOUSE_FOLLOW_SPEED
	else:
		CurrentFollowSpeed = FOLLOW_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	MousePosition = update_destination()
	position = position.lerp(Destination, delta * CurrentFollowSpeed)
	rotation = lerp(rotation, DestinedRotation, delta * CurrentFollowSpeed * 0.5)
	scale = scale.lerp(DestinedSize, delta * CurrentFollowSpeed)
