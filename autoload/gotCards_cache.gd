extends Node

var gotcardsIds: Array[int] = []

func _ready() -> void:
	SaveManager.connect("gotCardsChanged", invalidateCache) 

func getGotCardsIds() -> Array[int]:
	if gotcardsIds.is_empty():
		gotcardsIds = SaveManager.getGotCardsIds()
	
	return gotcardsIds

func invalidateCache() -> void:
	gotcardsIds.clear()
