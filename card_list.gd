extends HFlowContainer

var Database = preload("res://database.gd")
var CardScene = preload("res://card.tscn")
var SaveManager = preload("res://save_manager.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var db_manager = Database.new()
	var cardList = db_manager.getAllCards()
	var gotCards = SaveManager.getGotCards()

	for card in cardList:
		var cs = CardScene.instantiate()
		var card_data = cs.get_node("Card")
		var img_path = "res://img/cards/" + card.image
		card_data.id = card.id
		if gotCards.has(card.id):
			cs.get_node("Card/NotGotOverlay").hide()
			card_data.got = true
		
		#Styling
		cs.custom_minimum_size.x = 300
		cs.custom_minimum_size.y = 400
		cs.get_node("Card").scale = Vector2(0.7, 0.7)
		cs.get_node("Card/CardButton").texture_normal = load(img_path)
		
		add_child(cs)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
