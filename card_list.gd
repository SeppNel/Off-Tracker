extends HFlowContainer

# Static includes
const CardScene = preload("res://card.tscn")
const PROMOA_COL_ID = 999
const PROMOB_COL_ID = 998

# Node references
@onready var r_collectionSelect: OptionButton = $Controls/Level1/CollectionContainer/CollectionSelect

# Member variables
var m_onlyMissing: bool = false
var m_collectionFilter: int
var m_order: int = 0
var m_cardImgCache: Dictionary[String, Texture2D] = {}
var m_threaded_paths: Array[String]
var m_loading_in_progress: bool = false

var m_searchState: bool = false
var m_lastSearchName: String
var m_lastSearchType: int
var m_lastSearchStage: int
var m_lastSearchRarity: int
var m_lastSearchPack: int
var m_lastSearchWeakness: int

func preload_cardImages() -> void:
	for card in DbManager.getCardsInCollection(m_collectionFilter):
		var img_path: String = "res://img/cards/" + card.image
		m_cardImgCache[img_path] = load(img_path)
	
	m_loading_in_progress = true
	for card in DbManager.getAllCards():
		var img_path: String = "res://img/cards/" + card.image
		m_threaded_paths.append(img_path)
		ResourceLoader.load_threaded_request(img_path, "Texture2D")

	# Start checking periodically if done
	set_process(true)
	
func _process(_delta) -> void:
	if not m_loading_in_progress:
		return

	var all_done := true
	for path in m_threaded_paths:
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			if not m_cardImgCache.has(path):
				m_cardImgCache[path] = ResourceLoader.load_threaded_get(path)
		elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			all_done = false

	if all_done:
		m_loading_in_progress = false
		set_process(false)

func fillCollectionSelect() -> void:
	r_collectionSelect.clear()
	
	r_collectionSelect.add_item("All", 0)
	
	var collections: Array[Dictionary] = DbManager.getCollections()
	for i in range(collections.size()-1, -1, -1):
		r_collectionSelect.add_item(collections[i]["name"], collections[i]["id"])
	
	r_collectionSelect.add_item("Promo B", PROMOB_COL_ID)
	r_collectionSelect.add_item("Promo A", PROMOA_COL_ID)
	r_collectionSelect.selected = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fillCollectionSelect()
	m_collectionFilter = r_collectionSelect.get_item_id(1)
	preload_cardImages()
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

func addCollectionTitle(img: String) -> void:
	var marginTop := Control.new()
	marginTop.custom_minimum_size = Vector2(1080, 20)
	call_deferred("add_child", marginTop)
	var titleCont := CenterContainer.new()
	titleCont.custom_minimum_size = Vector2(1080, 200)
	var title := TextureRect.new()
	title.texture = load(img)
	titleCont.add_child(title)
	call_deferred("add_child", titleCont)

func addCardToList(card: Dictionary, gotCards: Dictionary[String, int]) -> void:
	var cs = CardScene.instantiate()
	var card_data = cs.get_node("Card")
	var img_path: String = "res://img/cards/" + card.image
	card_data.id = card.id
	
	var str_id := str(card.id)
	if gotCards.has(str_id):
		card_data.get_node("NotGotOverlay").hide()
		card_data.got = true
		card_data.set_count(gotCards[str_id])
		
	# Load from cache or load new
	if not m_cardImgCache.has(img_path):
		m_cardImgCache[img_path] = load(img_path)

	#Styling
	card_data.get_node("CardButton").texture_normal = m_cardImgCache[img_path]
	call_deferred("add_child", cs)
	

func addCollectionCards(cardList: Array[Dictionary], gotCards: Dictionary[String, int]) -> void:
	if m_onlyMissing:
		for card in cardList:
			if not gotCards.has(str(card.id)):
				addCardToList(card, gotCards)
	else:
		for card in cardList:
			addCardToList(card, gotCards)

func loadCards() -> void:
	m_searchState = false
	var gotCards := SaveManager.getGotCards()
	
	if m_collectionFilter == 0:
		var collections: Array[Dictionary] = DbManager.getCollections().duplicate()
		for col in collections:
			var name: String = col["name"]
			name = name.replace(" ", "_")
			name = name.replace("-", "_")
			name = name.to_lower()
			
			var collectionCards := DbManager.getCardsInCollection(col["id"], parse_order())
			addCollectionTitle("res://img/collections/" + name + ".webp")
			addCollectionCards(collectionCards, gotCards)
	elif m_collectionFilter == PROMOA_COL_ID:
		var collectionCards = DbManager.getPromoACards()
		addCollectionTitle("res://img/collections/promo_a.webp")
		addCollectionCards(collectionCards, gotCards)
	elif m_collectionFilter == PROMOB_COL_ID:
		var collectionCards = DbManager.getPromoBCards()
		addCollectionTitle("res://img/collections/promo_b.webp")
		addCollectionCards(collectionCards, gotCards)
	else:
		var name = DbManager.getCollectionName(m_collectionFilter)
		name = name.replace(" ", "_")
		name = name.replace("-", "_")
		name = name.to_lower()
		
		var collectionCards = DbManager.getCardsInCollection(m_collectionFilter, parse_order())
		addCollectionTitle("res://img/collections/" + name + ".webp")
		addCollectionCards(collectionCards, gotCards)
	

func clearCardList() -> void:
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
	
func loadCardsSearch(n, t, s, r, p, w) -> void:
	m_lastSearchName = n
	m_lastSearchType = t
	m_lastSearchStage = s
	m_lastSearchRarity = r
	m_lastSearchPack = p
	m_lastSearchWeakness = w
	m_searchState = true
	
	clearCardList()
	var cards = DbManager.search(n, t, s, r, p, w, parse_order())
	
	var gotCards := SaveManager.getGotCards()
	var title := Label.new()
	title.text = "    Search results"
	title.custom_minimum_size = Vector2(1080, 100)
	title.add_theme_font_size_override("font_size", 40)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(title)
	addCollectionCards(cards, gotCards)
