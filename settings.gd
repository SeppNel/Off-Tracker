extends VFlowContainer

var SaveManager = preload("res://save_manager.gd")
var filedialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_export_button_pressed() -> void:
	var file = FileAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/ptcgp_export.json", FileAccess.WRITE)  # Open file for writing
	if file:
		file.store_string(SaveManager.getSaveJson())  # Write content
		file.close()
		$Output.add_theme_color_override("font_color", Color(0, 1, 0))
		$Output.text = "File saved to Documents folder"
	else:
		$Output.add_theme_color_override("font_color", Color(1, 0, 0))
		$Output.text = "Failed to save file"
