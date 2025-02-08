extends TextureButton

var SaveManager = preload("res://save_manager.gd")

func _ready() -> void:
	pass # Replace with function body.

func _on_button_down() -> void:
	$"../HoldTimer".start()
	get_parent().mouse_position = get_viewport().get_mouse_position()


func _on_button_up() -> void:
	if not $"../HoldTimer".is_stopped():
		$"../HoldTimer".stop()
		
		var card = get_parent()
		var new_mouse_pos = get_viewport().get_mouse_position()
		var mouse_diff = abs(new_mouse_pos - card.mouse_position)
		if mouse_diff.x < card.SCROLL_OFFSET and mouse_diff.y < card.SCROLL_OFFSET and not card.got:
			card.got = true
			$"../NotGotOverlay".hide()
			SaveManager.saveNewCard(card.id)
			card.mouse_position = Vector2(-1,-1)
