extends PanelContainer

var DbManager = preload("res://static/database.gd")
var CardList
var MainSearchButton
var CollectionSelect

func _ready() -> void:
	CardList = %CardPage/CardList
	MainSearchButton = %CardPage/CardList/Controls/Search
	CollectionSelect = %CardPage/CardList/Controls/Level1/CollectionContainer/CollectionSelect



func _on_search_pressed() -> void:
	self.show()


func _on_accept_search_pressed() -> void:
	var name = $VFlowContainer/NameInput.text
	var type = $VFlowContainer/TypeInput.get_selected_id()
	var stage = $VFlowContainer/StageInput.get_selected_id()
	var rarity = $VFlowContainer/RarityInput.get_selected_id()
	var pack = $VFlowContainer/PackInput.get_selected_id()
	var weak = $VFlowContainer/WeaknessInput.get_selected_id()
	MainSearchButton.text = name
	CollectionSelect.disabled = true
	CardList.loadCardsSearch(name, type, stage, rarity, pack, weak)
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
	
	MainSearchButton.text = "Search..."
	CardList.m_searchState = false
	CollectionSelect.disabled = false
	CardList.update()
	
	self.hide()
