extends VBoxContainer

@export
var PACK_ID: int

const CARD_4_RATES_PRE_SHINY: Array[float] = [0.9, 0.05, 0.01666, 0.02572, 0.005, 0.00222, 0, 0, 0.0004]
const CARD_5_RATES_PRE_SHINY: Array[float] = [0.6, 0.2, 0.06664, 0.10288, 0.02, 0.00888, 0, 0, 0.0016]
const CARD_4_RATES_POST_SHINY: Array[float] = [0.89, 0.04952, 0.01666, 0.02572, 0.005, 0.00222, 0.00714, 0.00333, 0.0004]
const CARD_5_RATES_POST_SHINY: Array[float] = [0.56, 0.1981, 0.06664, 0.10288, 0.02, 0.00888, 0.02857, 0.01333, 0.0016]

const CARD_4_RATES_POST_MEGA: Array[float] = [0.89999, 0.05, 0.01667, 0.02572, 0.005, 0.00222, 0, 0, 0.0004]
const CARD_5_RATES_POST_MEGA: Array[float] = [0.59998, 0.2, 0.06667, 0.10286, 0.02, 0.00889, 0, 0, 0.0016]
const SHINY_RATES_POST_MEGA: Array[float] = [0, 0, 0, 0, 0, 0, 0.6818, 0.3182, 0]

var CARD_4_RATES: Array[float]
var CARD_5_RATES: Array[float]

func _ready() -> void:
	# If pack is before shining revelry, use the old rates
	if PACK_ID < 8:
		CARD_4_RATES = CARD_4_RATES_PRE_SHINY
		CARD_5_RATES = CARD_5_RATES_PRE_SHINY
	elif PACK_ID < 18:
		CARD_4_RATES = CARD_4_RATES_POST_SHINY
		CARD_5_RATES = CARD_5_RATES_POST_SHINY
	else:
		CARD_4_RATES = CARD_4_RATES_POST_MEGA
		CARD_5_RATES = CARD_5_RATES_POST_MEGA
	

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
	
func newCalcNewCardProbability() -> float:
	const Std_Chance = 0.947115
	const Shi_Chance = 0.052385
	const God_Chance = 0.0005

	var totalGotRarity: int = %HomePage.cardsOfRarity[1][PACK_ID]
	var totalRarity: int = DbManager.countRarityCardsFromPack(PACK_ID, 1)
	var remaining: int = totalRarity - totalGotRarity
	var newC1t3: float = 1.0 / totalRarity * remaining
	
	var totalInGod: int = 0
	var totalGotInGod: int = 0
	var newC4: float = 0
	var newC5: float = 0
	var newShiny: float = 0
	var r := 2
	while r <= 10:
		totalGotRarity = %HomePage.cardsOfRarity[r][PACK_ID]
		totalRarity = DbManager.countRarityCardsFromPack(PACK_ID, r)
		remaining = totalRarity - totalGotRarity
		if totalRarity != 0 and remaining != 0:
			if r == 8 || r == 9:
				newShiny += SHINY_RATES_POST_MEGA[r - 2] / totalRarity * remaining
			else:
				newC4 += CARD_4_RATES[r - 2] / totalRarity * remaining
				newC5 += CARD_5_RATES[r - 2] / totalRarity * remaining
				
		if (r >= 5 && r <= 7) || r == 10:
			totalGotInGod += totalGotRarity
			totalInGod += totalRarity

		r += 1
	
	var remainingGod: int = totalInGod - totalGotInGod
	var newInGod:float  = 1.0 / totalInGod * remainingGod
		
	var Std_Exct0: float = (1-newC1t3)*(1-newC1t3)*(1-newC1t3)*(1-newC4)*(1-newC5)
	var Shi_Exct0: float = (1-newC1t3)*(1-newC1t3)*(1-newC1t3)*(1-newC4)*(1-newC5)*(1-newShiny)
	var God_Exct0: float = pow((1 - newInGod), 5)
	var Std_atlst1: float = 1 - Std_Exct0
	var Shi_atlst1: float = 1 - Shi_Exct0
	var God_atlst1: float = 1 - God_Exct0
	
	return (Std_Chance*Std_atlst1)+(God_Chance*God_atlst1)+(Shi_Chance*Shi_atlst1)
	
func updateNewCardProbability() -> void:
	var p: float
	if PACK_ID == 16:
		return
	elif PACK_ID < 18:
		p = calcNewCardProbability()
	else:
		p = newCalcNewCardProbability()
	
	$Probability.text = str(snapped(p * 100, 0.001)) + "%"
