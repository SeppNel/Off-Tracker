extends HBoxContainer

var parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()

func _on_home_pressed() -> void:
	parent.get_node("CardPage").hide()
	parent.get_node("SettingsPage").hide()
	
	parent.get_node("HomePage").updateUi()
	parent.get_node("HomePage").show()

func _on_cards_pressed() -> void:
	parent.get_node("HomePage").hide()
	parent.get_node("SettingsPage").hide()
	
	parent.get_node("CardPage").show()

func _on_settings_pressed() -> void:
	parent.get_node("CardPage").hide()
	parent.get_node("HomePage").hide()
	
	parent.get_node("SettingsPage/Settings/Output").text = ""
	parent.get_node("SettingsPage").show()
