extends Node

var gotCardsIds: Array[int] = []

func _ready() -> void:
	SaveManager.connect("gotCardsChanged", invalidateCache) 

func getGotCardsIds() -> Array[int]:
	if gotCardsIds.is_empty():
		gotCardsIds = SaveManager.getGotCardsIds()
	
	return gotCardsIds

func invalidateCache() -> void:
	gotCardsIds.clear()
