extends VBoxContainer

var Database = preload("res://database.gd")
var SaveManager = preload("res://save_manager.gd")
var DbManager = Database.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateNumberofCards()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func updateNumberofCards():
	var cardIds = DbManager.getCardsIdFromPack(6)
	var gotCards = SaveManager.getGotCards()
	
	var gotCount: int = 0
	for id in gotCards:
		if id in cardIds:
			gotCount += 1
			
	$Numbers.text = str(gotCount) + " of " + str(cardIds.size())
