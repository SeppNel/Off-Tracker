extends ScrollContainer

var SaveManager = preload("res://save_manager.gd")
var DbManager = preload("res://database.gd")

var gotCards = []
var cardRarity_cache = {}
var cardPacks_cache = {}
var cardsOfRarity
var packsArray = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	packsArray = [
	$Home/GeneticApex/Packs/MewtwoPack,
	$Home/GeneticApex/Packs/CharizardPack,
	$Home/GeneticApex/Packs/PikachuPack,
	$Home/MythicalIsland/Packs/MewPack,
	$Home/SpaceTime/Packs/DialgaPack,
	$Home/SpaceTime/Packs/PalkiaPack
	]
	updateUi()
	
func updateUi():
	gotCards = SaveManager.getGotCards()
	countCardsOfRarity()

	for pack in packsArray:
		pack.gotCards = gotCards
		pack.update()

func initCardsOfRarity():
	cardsOfRarity = {
	1 : {1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0, 6 : 0},
	2 : {1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0, 6 : 0},
	3 : {1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0, 6 : 0},
	4 : {1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0, 6 : 0},
	5 : {1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0, 6 : 0},
	6 : {1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0, 6 : 0},
	7 : {1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0, 6 : 0},
	8 : {1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0, 6 : 0},
	}
			
func countCardsOfRarity():
	initCardsOfRarity()
	
	for card in gotCards:
		var rarity: int
		if card in cardRarity_cache:
			rarity = cardRarity_cache[card]
		else:
			rarity = DbManager.getCardRarity(card)
			cardRarity_cache[card] = rarity
			
		var packs
		if card in cardPacks_cache:
			packs = cardPacks_cache[card]
		else:
			packs = DbManager.getPacksOfCard(card)
			cardPacks_cache[card] = packs
		
		for pack_id in packs:
			if pack_id != 0:
				cardsOfRarity[rarity][pack_id] += 1
