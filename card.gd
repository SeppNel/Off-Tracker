extends CenterContainer

var SaveManager = preload("res://save_manager.gd")

const SCROLL_OFFSET = 10

var id: int
var got: bool
var mouse_position = Vector2(-1,-1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hold_timer_timeout() -> void:
	#delete card
	var new_mouse_pos = get_viewport().get_mouse_position()
	var mouse_diff = abs(new_mouse_pos - mouse_position)
	if mouse_diff.x < SCROLL_OFFSET and mouse_diff.y < SCROLL_OFFSET:
		SaveManager.removeSavedCard(id)
		$NotGotOverlay.show()
		got = false
		mouse_position = Vector2(-1,-1)
