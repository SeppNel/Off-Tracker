extends TextureButton

var SaveManager = preload("res://save_manager.gd")

var PublishModal

func _ready() -> void:
	PublishModal = get_tree().get_root().get_node("Root/DaddyDiv/FriendsPage/ScrollContainer/PublishModal")

func _on_button_down() -> void:
	$"../HoldTimer".start()
	get_parent().mouse_position = get_viewport().get_mouse_position()


func _on_button_up() -> void:
	if not $"../HoldTimer".is_stopped():
		$"../HoldTimer".stop()
		
		var card = get_parent()
		var new_mouse_pos = get_viewport().get_mouse_position()
		var mouse_diff = abs(new_mouse_pos - card.mouse_position)
		if mouse_diff.x < card.SCROLL_OFFSET and mouse_diff.y < card.SCROLL_OFFSET:
			if not card.got:
				card.got = true
				$"../NotGotOverlay".hide()
				SaveManager.saveCard(card.id)
				card.set_count(1)
			else:
				SaveManager.saveCard(card.id)
				card.set_count(card.count + 1)
				
			card.mouse_position = Vector2(-1,-1)

func _on_pubish_card_selected():
	var card = get_parent()
	print(card.id)
	
	if PublishModal.addWantCard(card.id):
		card.get_node("NotGotOverlay").visible = !card.get_node("NotGotOverlay").visible
