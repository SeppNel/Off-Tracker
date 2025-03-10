extends HFlowContainer

var DbManager = preload("res://static/database.gd")
var CardScene = preload("res://card.tscn")
var SaveManager = preload("res://static/save_manager.gd")

func update() -> void:
	clear()
	addCards()
	
func clear():
	for child in get_children():
		child.queue_free()

func addCards() -> void:
	var gotCards = SaveManager.getGotCards()
	var cardList = DbManager.getTradeableCards()
	for card in cardList:
		if not gotCards.has(str(card.id)):
			addCardToList(card, gotCards)
			
func addCardToList(card, gotCards):
	var cs = CardScene.instantiate()
	var button = cs.get_node("Card/CardButton")
	button.disconnect("button_down", button._on_button_down)
	button.disconnect("button_up", button._on_button_up)
	button.connect("pressed", button._on_pubish_card_selected)
	var card_data = cs.get_node("Card")
	var img_path = "res://img/cards/" + card.image
	card_data.id = card.id
	
	#Styling
	card_data.get_node("Counter").hide()
	cs.get_node("Card/CardButton").texture_normal = load(img_path)
	add_child(cs)
