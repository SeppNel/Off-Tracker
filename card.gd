extends Control

var SaveManager = preload("res://save_manager.gd")

const SCROLL_OFFSET = 10

var id: int
var got: bool
var count: int
var mouse_position = Vector2(-1,-1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_hold_timer_timeout() -> void:
	#delete card
	var new_mouse_pos = get_viewport().get_mouse_position()
	var mouse_diff = abs(new_mouse_pos - mouse_position)
	if mouse_diff.x < SCROLL_OFFSET and mouse_diff.y < SCROLL_OFFSET:
		SaveManager.removeSavedCard(id)
		set_count(count - 1)
		if count < 1:
			$NotGotOverlay.show()
			got = false
		mouse_position = Vector2(-1,-1)
		
func set_count(c: int):
	count = c
	$Counter.text = str(count)
