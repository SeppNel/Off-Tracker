extends ScrollContainer

const SaveManager = preload("res://static/save_manager.gd")
const DbManager = preload("res://static/database.gd")
const MAX_RARITY = 10

var gotCards = []
var cardRarity_cache = {}
var cardPacks_cache = {}
var cardsOfRarity : Dictionary
var packsArray = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	packsArray = [
	$Home/GeneticApex/Packs/MewtwoPack,
	$Home/GeneticApex/Packs/CharizardPack,
	$Home/GeneticApex/Packs/PikachuPack,
	$Home/MythicalIsland/Packs/MewPack,
	$Home/SpaceTime/Packs/DialgaPack,
	$Home/SpaceTime/Packs/PalkiaPack,
	$Home/TriumphantLight/Packs/ArceusPack,
	$Home/ShiningRevelry/Packs/ShiningPack,
	$Home/CelestialGuardians/Packs/SolgaleoPack,
	$Home/CelestialGuardians/Packs/LunalaPack
	]
	updateUi()
	
func updateUi():
	gotCards = SaveManager.getGotCardsIds()
	countCardsOfRarity()

	for pack in packsArray:
		pack.gotCards = gotCards
		pack.update()

func initCardsOfRarity():
	for rarity in range(1, MAX_RARITY + 1):
		cardsOfRarity[rarity] = {}
		for pack in range(1, packsArray.size() + 1):
			cardsOfRarity[rarity][pack] = 0
			
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
