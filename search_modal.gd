extends PanelContainer

@onready var r_CardList = %CardPage/CardList
@onready var r_MainSearchButton = %CardPage/CardList/Controls/Search
@onready var r_CollectionSelect = %CardPage/CardList/Controls/Level1/CollectionContainer/CollectionSelect
@onready var r_PackInput: OptionButton = $VFlowContainer/PackInput

func fillPackInput() -> void:
	r_PackInput.add_item("Any", 0)
	
	var packs: Array[Dictionary] = DbManager.getPacks()
	for p in packs:
		r_PackInput.add_item(p["name"], p["id"])

func _ready() -> void:
	fillPackInput()

func _on_search_pressed() -> void:
	self.show()

func _on_accept_search_pressed() -> void:
	var name = $VFlowContainer/NameInput.text
	var type = $VFlowContainer/TypeInput.get_selected_id()
	var stage = $VFlowContainer/StageInput.get_selected_id()
	var rarity = $VFlowContainer/RarityInput.get_selected_id()
	var pack = $VFlowContainer/PackInput.get_selected_id()
	var weak = $VFlowContainer/WeaknessInput.get_selected_id()
	r_MainSearchButton.text = name
	r_CollectionSelect.disabled = true
	r_CardList.loadCardsSearch(name, type, stage, rarity, pack, weak)
	self.hide()

func _on_cancel_search_pressed() -> void:
	self.hide()

func _on_clear_search_pressed() -> void:
	$VFlowContainer/NameInput.text = ""
	$VFlowContainer/TypeInput.selected = 0
	$VFlowContainer/StageInput.selected = 0
	$VFlowContainer/RarityInput.selected = 0
	$VFlowContainer/PackInput.selected = 0
	$VFlowContainer/WeaknessInput.selected = 0
	
	r_MainSearchButton.text = "Search..."
	r_CardList.m_searchState = false
	r_CollectionSelect.disabled = false
	r_CardList.update()
	
	self.hide()
