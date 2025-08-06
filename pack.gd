extends VBoxContainer

@export
var PACK_ID: int

const CARD_4_RATES_PRE_SHINY: Array[float] = [0.9, 0.05, 0.01666, 0.02572, 0.005, 0.00222, 0, 0, 0.0004]
const CARD_5_RATES_PRE_SHINY: Array[float] = [0.6, 0.2, 0.06664, 0.10288, 0.02, 0.00888, 0, 0, 0.0016]
const CARD_4_RATES_POST_SHINY: Array[float] = [0.89, 0.04952, 0.01666, 0.02572, 0.005, 0.00222, 0.00714, 0.00333, 0.0004]
const CARD_5_RATES_POST_SHINY: Array[float] = [0.56, 0.1981, 0.06664, 0.10288, 0.02, 0.00888, 0.02857, 0.01333, 0.0016]

var CARD_4_RATES: Array[float]
var CARD_5_RATES: Array[float]

func _ready() -> void:
	# If pack is before shining revelry, use the old rates
	if PACK_ID < 8:
		CARD_4_RATES = CARD_4_RATES_PRE_SHINY
		CARD_5_RATES = CARD_5_RATES_PRE_SHINY
	else:
		CARD_4_RATES = CARD_4_RATES_POST_SHINY
		CARD_5_RATES = CARD_5_RATES_POST_SHINY
	

func update() -> void:
	updateNumberofCards()
	updateNewCardProbability()

func updateNumberofCards() -> void:
	var cardIds = DbManager.getCardsIdFromPack(PACK_ID)
	
	var gotCount: int = 0
	for id in GotCardsCache.getGotCardsIds():
		if id in cardIds:
			gotCount += 1
			
	$Numbers.text = str(gotCount) + " of " + str(cardIds.size())

#Blatanly stolen from https://docs.google.com/spreadsheets/u/0/d/1BnU0G8VhMT-DyawxNJS-n9KeUEqWL0qAF4qa4S-Xvx8/htmlview
func calcNewCardProbability() -> float:
	var rarityOne = %HomePage.cardsOfRarity[1][PACK_ID]
	var countRarityOne = DbManager.countRarityCardsFromPack(PACK_ID, 1)
	var remaining = countRarityOne - rarityOne
	var M13: float = 1.0 / countRarityOne * remaining
	
	var N24 = 0
	var P24 = 0
	var r = 2
	while r <= 10:
		var totalGotRarity = %HomePage.cardsOfRarity[r][PACK_ID]
		var totalRarity = DbManager.countRarityCardsFromPack(PACK_ID, r)
		remaining = totalRarity - totalGotRarity
		if totalRarity != 0 and remaining != 0:
			N24 += CARD_4_RATES[r - 2] / totalRarity * remaining
			P24 += CARD_5_RATES[r - 2] / totalRarity * remaining
		r += 1

	var N28 = (1-M13)*(1-M13)*(1-M13)*(1-N24)*(1-P24)
	return 1 - N28
	
func updateNewCardProbability() -> void:
	var p = calcNewCardProbability()
	$Probability.text = str(snapped(p * 100, 0.001)) + "%" 
