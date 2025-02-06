extends HFlowContainer

var DbManager = preload("res://database.gd")
var CardScene = preload("res://card.tscn")
var SaveManager = preload("res://save_manager.gd")

var OnlyMissing: bool = 0
var CollectionFilter: int = 0
var Order: int = 0
var cardImg_cache = {}

func preload_cardImages(cards):
	for card in cards:
		var img_path = "res://img/cards/" + card.image
		cardImg_cache[img_path] = load(img_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preload_cardImages(DbManager.getAllCards())
	loadCards(OnlyMissing, CollectionFilter)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func parseOrder(order: int) -> String:
	match order:
		0:
			return "c.id ASC"
		1:
			return "c.id DESC"
		2:
			return "c.rarity ASC"
		3:
			return "c.rarity DESC"
		_:
			return ""

func addCollectionTitle(img: String):
	var marginTop = Control.new()
	marginTop.custom_minimum_size = Vector2(1080, 20)
	add_child(marginTop)
	var titleCont = CenterContainer.new()
	titleCont.custom_minimum_size = Vector2(1080, 200)
	var title = TextureRect.new()
	title.texture = load(img)
	titleCont.add_child(title)
	add_child(titleCont)

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
	cs.get_node("Card/CardButton").texture_normal = cardImg_cache[img_path]
	add_child(cs)
	

func addCollectionCards(cardList, gotCards, onlyMissing : bool = 0):
	if onlyMissing:
		for card in cardList:
			if not gotCards.has(card.id):
				addCardToList(card, gotCards)
	else:
		for card in cardList:
			addCardToList(card, gotCards)

func loadCards(missingOnly: bool = 0, collection: int = 0):
	var gotCards = SaveManager.getGotCards()
	
	if collection == 1 or collection == 0:
		var genApexCards = DbManager.getGeneticApexCards(parseOrder(Order))
		addCollectionTitle("res://img/genetic_apex.png")
		addCollectionCards(genApexCards, gotCards, missingOnly)
			
	if collection == 2 or collection == 0:
		var mythIslandCards = DbManager.getMythicalIslandsCards(parseOrder(Order))
		addCollectionTitle("res://img/mythical_island.png")
		addCollectionCards(mythIslandCards, gotCards, missingOnly)
	
	if collection == 3 or collection == 0:
		var spaceTimeCards = DbManager.getSpaceTimeCards(parseOrder(Order))
		addCollectionTitle("res://img/space_time_smackdown.png")
		addCollectionCards(spaceTimeCards, gotCards, missingOnly)
			
	if collection == 4 or collection == 0:
		var promoCards = DbManager.getPromoCards()
		addCollectionTitle("res://img/promo_a.png")
		addCollectionCards(promoCards, gotCards, missingOnly)

func clearCardList():
	for child in get_children():
		if child.name != "Controls" and child.name != "MarginTop":  # Ensure we don't remove the controls
			child.queue_free()

func _on_only_missing_check_pressed() -> void:
	OnlyMissing = !OnlyMissing
	clearCardList()
	loadCards(OnlyMissing, CollectionFilter)

func _on_collection_select_item_selected(index: int) -> void:
	CollectionFilter = index
	clearCardList()
	loadCards(OnlyMissing, CollectionFilter)

func _on_order_select_item_selected(index: int) -> void:
	Order = index
	clearCardList()
	loadCards(OnlyMissing, CollectionFilter)
