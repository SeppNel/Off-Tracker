extends VBoxContainer

const DbManager = preload("res://static/database.gd")
const CardScene = preload("res://card.tscn")
const SaveManager = preload("res://static/save_manager.gd")

var gotCards = SaveManager.getGotCards()

func setName(n: String) -> void:
	$Name.text = n

func addMissingCard(id: int) -> void:
	var card = DbManager.getCard(id)
	addCardToList(card, $MissingContainer/Cards)
	
func addOfferCard(id: int) -> void:
	$OfferContainer/NoOffer.hide()
	$OfferContainer/Cards.show()
	
	var card = DbManager.getCard(id)
	addCardToList(card, $OfferContainer/Cards)


func addCardToList(card, container):
	var cs = CardScene.instantiate()
	var button = cs.get_node("Card/CardButton")
	button.disconnect("button_down", button._on_button_down)
	button.disconnect("button_up", button._on_button_up)
	var card_data = cs.get_node("Card")
	var img_path = "res://img/cards/" + card.image
	card_data.id = card.id
	
	if gotCards.has(str(card.id)):
		cs.get_node("Card/NotGotOverlay").hide()
		card_data.got = true
		card_data.set_count(gotCards[str(card.id)])

	#Styling
	cs.get_node("Card/CardButton").texture_normal = load(img_path)
	container.add_child(cs)
