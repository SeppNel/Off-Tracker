extends ScrollContainer

var SaveManager = preload("res://save_manager.gd")
var DbManager = preload("res://database.gd")

var gotCards = []
var cardRarity_cache = {}
var cardPacks_cache = {}
var cardsOfRarity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateUi()
	
func updateUi():
	gotCards = SaveManager.getGotCards()
	$Home/GeneticApex/Packs/MewtwoPack.gotCards = gotCards
	$Home/GeneticApex/Packs/CharizardPack.gotCards = gotCards
	$Home/GeneticApex/Packs/PikachuPack.gotCards = gotCards
	$Home/MythicalIsland/Packs/MewPack.gotCards = gotCards
	$Home/SpaceTime/Packs/DialgaPack.gotCards = gotCards
	$Home/SpaceTime/Packs/PalkiaPack.gotCards = gotCards
	
	var start = Time.get_ticks_usec()
	countCardsOfRarity()
	var end = Time.get_ticks_usec()
	print("Count: ", (end - start) / 1000, " ms")

	$Home/GeneticApex/Packs/MewtwoPack.update()
	$Home/GeneticApex/Packs/CharizardPack.update()
	$Home/GeneticApex/Packs/PikachuPack.update()
	$Home/MythicalIsland/Packs/MewPack.update()
	$Home/SpaceTime/Packs/DialgaPack.update()
	$Home/SpaceTime/Packs/PalkiaPack.update()

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
			cardsOfRarity[rarity][pack_id] += 1
