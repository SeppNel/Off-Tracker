extends HFlowContainer

var Database = preload("res://database.gd")
var CardScene = preload("res://card.tscn")
var SaveManager = preload("res://save_manager.gd")

func addCollectionTitle(img: String):
	var marginTop = Container.new()
	marginTop.custom_minimum_size = Vector2(1080, 90)
	add_child(marginTop)
	var genCont = CenterContainer.new()
	genCont.custom_minimum_size = Vector2(1080, 200)
	var gen = TextureRect.new()
	gen.texture = load(img)
	genCont.add_child(gen)
	add_child(genCont)
	
func addCardToList(card, gotCards):
	var cs = CardScene.instantiate()
	var card_data = cs.get_node("Card")
	var img_path = "res://img/cards/" + card.image
	card_data.id = card.id
	if gotCards.has(card.id):
		cs.get_node("Card/NotGotOverlay").hide()
		card_data.got = true
	
	#Styling
	cs.get_node("Card").scale = Vector2(0.7, 0.7)
	cs.get_node("Card/CardButton").texture_normal = load(img_path)
	add_child(cs)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var db_manager = Database.new()
	var gotCards = SaveManager.getGotCards()
	var genApexCards = db_manager.getGeneticApexCards()
	var mythIslandCards = db_manager.getMythicalIslandsCards()
	var promoCards = db_manager.getPromoCards()
	
	addCollectionTitle("res://img/genetic_apex.png")
	for card in genApexCards:
		addCardToList(card, gotCards)
		
	addCollectionTitle("res://img/mythical_island.png")
	for card in mythIslandCards:
		addCardToList(card, gotCards)
		
	addCollectionTitle("res://img/promo_a.png")
	for card in promoCards:
		addCardToList(card, gotCards)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
