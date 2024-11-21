extends Node

var CardImages: Node2D = preload("res://scenes/card_images.tscn").instantiate()

enum DeckType {MAGE, WARRIOR, LANCER} 

var CARD_TROLLE: CardInfo = CardInfo.new(1 ,"Trolle", "While in Hand, the player shoots [color=red]Fireballs[/color]. (stacks)", 10, CardImages.get_normal_trollface(), false)
var CARD_STUFF: CardInfo = CardInfo.new(2, "Stuff", "[color=green]PLay[/color]: Wide explosion.", 20, CardImages.get_moving_stuff(), true)
var CARD_AMOGUS: CardInfo = CardInfo.new(3, "Amogus", "[color=green]PLay[/color]: Small explosion.", 5, CardImages.get_rotating_amogus(), true)
var CARD_CLOCK: CardInfo = CardInfo.new(4, "Clock", "[color=green]PLay[/color]: Big explosion.", 40, CardImages.get_clock(), true)

var CARD_LOOK_UP: Dictionary = {CARD_TROLLE.ID: CARD_TROLLE,
								CARD_STUFF.ID : CARD_STUFF,
								CARD_AMOGUS.ID: CARD_AMOGUS,
								CARD_CLOCK.ID: CARD_CLOCK}
