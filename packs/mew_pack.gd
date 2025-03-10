extends VBoxContainer

var DbManager = preload("res://static/database.gd")
var SaveManager = preload("res://static/save_manager.gd")

const PACK_ID = 1
const CARD_4_RATES = [0.9, 0.05, 0.01666, 0.02572, 0.005, 0.00222, 0.0004]
const CARD_5_RATES = [0.6, 0.2, 0.06664, 0.10288, 0.02, 0.00888, 0.0016]

var gotCards = []

func update():
	updateNumberofCards()
	updateNewCardProbability()

func updateNumberofCards():
	var cardIds = DbManager.getCardsIdFromPack(PACK_ID)
	
	var gotCount: int = 0
	for id in gotCards:
		if id in cardIds:
			gotCount += 1
			
	$Numbers.text = str(gotCount) + " of " + str(cardIds.size())

#Blatanly stolen from https://docs.google.com/spreadsheets/u/0/d/1BnU0G8VhMT-DyawxNJS-n9KeUEqWL0qAF4qa4S-Xvx8/htmlview
func calcNewCardProbability():
	var rarityOne = %HomePage.cardsOfRarity[1][PACK_ID]
	var countRarityOne = DbManager.countRarityCardsFromPack(PACK_ID, 1)
	var remaining = countRarityOne - rarityOne
	var M13 = (0.02 * remaining)
	
	var N24 = 0
	var P24 = 0
	var r = 2
	while r <= 8:
		var totalGotRarity = %HomePage.cardsOfRarity[r][PACK_ID]
		var totalRarity = DbManager.countRarityCardsFromPack(PACK_ID, r)
		remaining = totalRarity - totalGotRarity
		N24 += CARD_4_RATES[r - 2] / totalRarity * remaining
		P24 += CARD_5_RATES[r - 2] / totalRarity * remaining
		r += 1

	var N28 = (1-M13)*(1-M13)*(1-M13)*(1-N24)*(1-P24)
	return 1 - N28
	
func updateNewCardProbability():
	var p = calcNewCardProbability()
	$Probability.text = str(snapped(p * 100, 0.001)) + "%" 
