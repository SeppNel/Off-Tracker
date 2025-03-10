extends HFlowContainer

# Static includes
const DbManager = preload("res://static/database.gd")
const CardScene = preload("res://card.tscn")
const SaveManager = preload("res://static/save_manager.gd")

# Node references
var r_collectionSelect

# Member variables
var m_onlyMissing: bool = false
var m_collectionFilter: int = 0
var m_order: int = 0
var m_cardImgCache = {}

var m_searchState: bool = false
var m_lastSearchName: String
var m_lastSearchType: int
var m_lastSearchStage: int
var m_lastSearchRarity: int
var m_lastSearchPack: int
var m_lastSearchWeakness: int

func preload_cardImages(cards):
	for card in cards:
		var img_path = "res://img/cards/" + card.image
		m_cardImgCache[img_path] = load(img_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	r_collectionSelect = $Controls/Level1/CollectionContainer/CollectionSelect
	preload_cardImages(DbManager.getAllCards())
	loadCards()
	
func update() -> void:
	clearCardList()
	if m_searchState:
		loadCardsSearch(m_lastSearchName, m_lastSearchType, m_lastSearchStage, m_lastSearchRarity, m_lastSearchPack, m_lastSearchWeakness)
	else:
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
	call_deferred("add_child", titleCont)

func addCardToList(card, gotCards):
	var cs = CardScene.instantiate()
	var card_data = cs.get_node("Card")
	var img_path = "res://img/cards/" + card.image
	card_data.id = card.id
	
	var str_id = str(card.id)
	if gotCards.has(str_id):
		card_data.get_node("NotGotOverlay").hide()
		card_data.got = true
		card_data.set_count(gotCards[str_id])

	#Styling
	card_data.get_node("CardButton").texture_normal = m_cardImgCache[img_path]
	call_deferred("add_child", cs)
	

func addCollectionCards(cardList, gotCards):
	if m_onlyMissing:
		for card in cardList:
			if not gotCards.has(str(card.id)):
				addCardToList(card, gotCards)
	else:
		for card in cardList:
			addCardToList(card, gotCards)

func loadCards():
	m_searchState = false
	var gotCards = SaveManager.getGotCards()

	if m_collectionFilter == 1 or m_collectionFilter == 0:
		var genApexCards = DbManager.getGeneticApexCards(parse_order())
		addCollectionTitle("res://img/genetic_apex.webp")
		addCollectionCards(genApexCards, gotCards)
			
	if m_collectionFilter == 2 or m_collectionFilter == 0:
		var mythIslandCards = DbManager.getMythicalIslandsCards(parse_order())
		addCollectionTitle("res://img/mythical_island.webp")
		addCollectionCards(mythIslandCards, gotCards)
	
	if m_collectionFilter == 3 or m_collectionFilter == 0:
		var spaceTimeCards = DbManager.getSpaceTimeCards(parse_order())
		addCollectionTitle("res://img/space_time_smackdown.webp")
		addCollectionCards(spaceTimeCards, gotCards)
		
	if m_collectionFilter == 5 or m_collectionFilter == 0:
		var tlCards = DbManager.getTriumphantLightCards(parse_order())
		addCollectionTitle("res://img/triumphant_light.webp")
		addCollectionCards(tlCards, gotCards)
	
	if m_collectionFilter == 4 or m_collectionFilter == 0:
		var promoCards = DbManager.getPromoCards()
		addCollectionTitle("res://img/promo_a.webp")
		addCollectionCards(promoCards, gotCards)

func clearCardList():
	for child in get_children():
		if child.name != "Controls" and child.name != "MarginTop":  # Ensure we don't remove the controls
			child.queue_free()

func _on_only_missing_check_pressed() -> void:
	m_onlyMissing = !m_onlyMissing
	update()

func _on_collection_select_item_selected(index: int) -> void:
	m_collectionFilter = r_collectionSelect.get_item_id(index)
	update()

func _on_order_select_item_selected(index: int) -> void:
	m_order = index
	update()
	
func loadCardsSearch(n, t, s, r, p, w):
	m_lastSearchName = n
	m_lastSearchType = t
	m_lastSearchStage = s
	m_lastSearchRarity = r
	m_searchState = true
	
	clearCardList()
	var cards = DbManager.search(n, t, s, r, p, w, parse_order())
	
	var gotCards = SaveManager.getGotCards()
	var title = Label.new()
	title.text = "    Search results"
	title.custom_minimum_size = Vector2(1080, 100)
	title.add_theme_font_size_override("font_size", 40)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(title)
	addCollectionCards(cards, gotCards)
	

func has_card_id(data, card_id: int) -> bool:
	for card in data:
		if card.id == card_id:
			return true
	return false
