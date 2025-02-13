extends HFlowContainer

var DbManager = preload("res://database.gd")
var CardScene = preload("res://card.tscn")
var SaveManager = preload("res://save_manager.gd")

var m_onlyMissing: bool = 0
var m_collectionFilter: int = 0
var m_order: int = 0
var m_cardImgCache = {}

func preload_cardImages(cards):
	for card in cards:
		var img_path = "res://img/cards/" + card.image
		m_cardImgCache[img_path] = load(img_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preload_cardImages(DbManager.getAllCards())
	loadCards()
	
func update() -> void:
	clearCardList()
	loadCards()

func parse_order() -> String:
	match m_order:
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
	cs.get_node("Card/CardButton").texture_normal = m_cardImgCache[img_path]
	add_child(cs)
	

func addCollectionCards(cardList, gotCards):
	if m_onlyMissing:
		for card in cardList:
			if not gotCards.has(card.id):
				addCardToList(card, gotCards)
	else:
		for card in cardList:
			addCardToList(card, gotCards)

func loadCards():
	var gotCards = SaveManager.getGotCards()
	if m_collectionFilter == 1 or m_collectionFilter == 0:
		var genApexCards = DbManager.getGeneticApexCards(parse_order())
		addCollectionTitle("res://img/genetic_apex.png")
		addCollectionCards(genApexCards, gotCards)
			
	if m_collectionFilter == 2 or m_collectionFilter == 0:
		var mythIslandCards = DbManager.getMythicalIslandsCards(parse_order())
		addCollectionTitle("res://img/mythical_island.png")
		addCollectionCards(mythIslandCards, gotCards)
	
	if m_collectionFilter == 3 or m_collectionFilter == 0:
		var spaceTimeCards = DbManager.getSpaceTimeCards(parse_order())
		addCollectionTitle("res://img/space_time_smackdown.png")
		addCollectionCards(spaceTimeCards, gotCards)
			
	if m_collectionFilter == 4 or m_collectionFilter == 0:
		var promoCards = DbManager.getPromoCards()
		addCollectionTitle("res://img/promo_a.png")
		addCollectionCards(promoCards, gotCards)

func clearCardList():
	for child in get_children():
		if child.name != "Controls" and child.name != "MarginTop":  # Ensure we don't remove the controls
			child.queue_free()

func _on_only_missing_check_pressed() -> void:
	m_onlyMissing = !m_onlyMissing
	update()

func _on_collection_select_item_selected(index: int) -> void:
	m_collectionFilter = index
	update()

func _on_order_select_item_selected(index: int) -> void:
	m_order = index
	update()
