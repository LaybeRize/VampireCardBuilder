extends Node2D

@export var DeckType: int = Constants.DeckType.MAGE
@export var MaxHandSize: int = 10

@onready var CardScene: PackedScene = preload("res://scenes/card.tscn")
@onready var CardImages: Node2D = preload("res://scenes/card_images.tscn").instantiate()
@onready var Explosion: PackedScene = preload("res://smoke_explosion/smoke_explosion.tscn")
@onready var SpawnPoint = $CanvasLayer/Spawn
@onready var Player: Node2D = get_parent().get_node("World/Player")
@onready var World: Node2D = get_parent().get_node("World")

const HandRadius: int = 1300
const StartPosition: int = HandRadius - 400
const MiddleAngle: float = 270
const LowestAngle: float = 240
const AngleRange: float = (MiddleAngle - LowestAngle) * 2

var CurrentCursor: int = -1
var ClickedCard: int = -1

var HandSize: int = 0
var Hand: Array[Card] = []
var HandCursor: Array[bool] = []
var Deck: Dictionary = {Constants.CARD_STUFF: 2,
						Constants.CARD_CLOCK: 1,
						Constants.CARD_AMOGUS: 1,
						Constants.CARD_TROLLE: 4}
var DeckKeys: Array = Deck.keys()

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	SpawnPoint.position.y += HandRadius

# Math stuff for card positioning
func get_circle_position(AngleInDegree: float) -> Vector2:
	var x: float = HandRadius * cos(deg_to_rad(AngleInDegree))
	var y: float = (HandRadius * sin(deg_to_rad(AngleInDegree))) * 0.7
	return Vector2(x, y - HandRadius * 0.4)

func get_card_offset(pos: int) -> Vector2:
	var parts: float = AngleRange / (HandSize + 1)
	return get_circle_position(LowestAngle + (pos * parts))

func get_card_rotation(pos: int) -> float:
	var parts: float = AngleRange / (HandSize + 1)
	return ((LowestAngle + (pos * parts)) - MiddleAngle) * 0.01

# Temporary function for freeing destroyed cards
func remove_card_and_free(index: int):
	var c = remove_card(index)
	c.queue_free()

# 
func remove_card(index: int) -> Node2D:
	HandSize -= 1
	CurrentCursor = -1
	ClickedCard = -1
	var item = Hand[index]
	SpawnPoint.remove_child(item)
	Hand.remove_at(index)
	HandCursor.remove_at(index)
	update_hand_position()
	return item

func add_card_to_spawn(cardSpawner: CardInfo):
	if Constants.CARD_TROLLE.ID == cardSpawner.ID:
		Player.change_fireballs(1)
	
	HandSize += 1
	var card = cardSpawner.get_card(StartPosition)
	SpawnPoint.add_child(card)
	card.mouse_entered.connect(_handel_card_touched)
	card.mouse_exited.connect(_handel_card_untouched)
	Hand.push_front(card)
	HandCursor.push_front(false)
	update_hand_position()

func _handel_card_touched(card: Card):
	var pos = Hand.find(card)
	HandCursor[pos] = true
	_update_cards()

func _handel_card_untouched(card: Card):
	var pos = Hand.find(card)
	HandCursor[pos] = false
	_update_cards()

func _update_cards():
	if ClickedCard != -1:
		return
	
	var pos = HandCursor.find(true)
	if CurrentCursor == pos or (CurrentCursor != -1 and HandCursor[CurrentCursor]):
		return
	
	if CurrentCursor != -1:
		_update_card(CurrentCursor, false)
	
	if pos != -1:
		_update_card(pos, true)
		
	CurrentCursor = pos

func _update_card(pos: int, mouse: bool):
		Hand[pos].MouseOnMe = mouse
		Hand[pos].update_parameter()
		if mouse:
			SpawnPoint.move_child(Hand[pos], -1)
		else:
			SpawnPoint.move_child(Hand[pos], -(pos + 1))

func update_hand_position():
	for index in Hand.size():
		Hand[index].set_new_position_and_rotation(get_card_offset(1 + index), get_card_rotation(1 + index))

func draw_new_card(pos: int):	
	var key: CardInfo = DeckKeys[pos] 
	if Deck[key] > 0:
		Deck[key] -= 1
		add_card_to_spawn(key)
	if Deck[key] <= 0:
		DeckKeys.erase(key)

func add_card_back_to_deck(card: Card):
	var key = Constants.CARD_LOOK_UP[card.CardID]
	if Deck[key] == 0:
		DeckKeys.append(key)
	Deck[key] += 1
	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT and CurrentCursor != -1 \
				and Hand[CurrentCursor].CardCost <= 0:
			discard_card(CurrentCursor)
			_update_cards()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and CurrentCursor != -1:
			Hand[CurrentCursor].update_mouse_clicked(true)
			ClickedCard = CurrentCursor
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and ClickedCard != -1:
			if Hand[ClickedCard].Played and Hand[ClickedCard].CardCost <= 0:
				play_card(ClickedCard)
			else:
				Hand[ClickedCard].update_mouse_clicked(false)
				ClickedCard = -1

func play_card(card_pos: int):
	var c = remove_card(card_pos)
	add_card_back_to_deck(c)
	execute_card_action(c)
	c.queue_free()

func execute_card_action(c: Card):
	var newSmoke = Explosion.instantiate()
	newSmoke.global_position = Player.global_position
	
	if c.CardID == Constants.CARD_AMOGUS.ID:
		newSmoke.Damage = 20.0
	elif c.CardID == Constants.CARD_CLOCK.ID:
		newSmoke.Damage = 100.0
		newSmoke.scale *= 5
	elif c.CardID == Constants.CARD_STUFF.ID:
		newSmoke.Damage = 40.0
		newSmoke.scale.x = 3
		
	World.add_child(newSmoke)

func discard_card(card_pos: int):
	var c = remove_card(card_pos)
	add_card_back_to_deck(c)
	if c.CardID == Constants.CARD_TROLLE.ID:
		Player.change_fireballs(-1)
	c.queue_free()

func _process(_delta):
	if HandSize < MaxHandSize and DeckKeys.size() > 0:
		draw_new_card(rng.randi_range(0,DeckKeys.size() - 1))

func _on_timer_timeout():
	for card in Hand:
		if card.CardCost > 0:
			card.set_new_card_cost(card.CardCost - 1)
