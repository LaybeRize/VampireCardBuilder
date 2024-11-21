class_name CardInfo

var card: Card
var image: Node2D
@export var ID: int = -1
	
func _init(_id: int, _name: String, _desc: String, _cost: int, _image: Node2D, _can_be_played: bool):
	ID = _id
	card = preload("res://scenes/card.tscn").instantiate()
	card.CardID = ID
	card.CardName = _name
	card.CardDescription = _desc
	card.CardCost = _cost
	image = _image
	card.CanBePlayed = _can_be_played

func get_card(y_offset: int) -> Card:
	var newCard = card.duplicate()
	newCard.Y_Offset = y_offset
	newCard.CardImage = image.duplicate()
	return newCard
