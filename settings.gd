extends VFlowContainer

var SaveManager = preload("res://save_manager.gd")
var android_picker
var filedialog
var filledHeartIcon = preload("res://img/donate_filled.webp")

func _ready() -> void:
	if Engine.has_singleton("GodotFilePicker"):
		android_picker = Engine.get_singleton("GodotFilePicker")
		android_picker.file_picked.connect(_on_read_file_picked)
	
	if SaveManager.m_friend_code != -1:
		$VFlowContainer/FCContainer/FriendCodeLabel.text = "Friend Code: " + str(SaveManager.m_friend_code)

func _on_export_button_pressed() -> void:
	var file = FileAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/ptcgp_export.json", FileAccess.WRITE)  # Open file for writing
	if file:
		file.store_string(SaveManager.getSaveJson())  # Write content
		file.close()
		showSuccess("File saved to Documents folder")
	else:
		showError("Failed to save file")

func _on_import_button_pressed() -> void:
	if OS.get_name() == "Android":
		android_picker.openFilePicker("application/json")
	else:
		nativeFileDialog()

func _on_read_file_picked(temp_path: String, mime_type: String) -> void:
	var file = FileAccess.open(temp_path, FileAccess.READ)
	if file:
		var fail: bool = false
		var file_content = file.get_as_text()
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string
		if not json.parse(file_content) == OK:
			showError("Failed to import")
			fail = true

		# Get the data from the JSON object
		var data = json.get_data()
		if not data.has("got_cards"):
			showError("File not valid")
			fail = true
		
		if not fail:	
			DirAccess.copy_absolute(temp_path, SaveManager.SAVE_PATH)
			SaveManager.checkVersion()
			%CardPage/CardList.update()
			SaveManager.update()
			showSuccess("Import successful")

		file.close()
	else:
		showError("Failed to import")
	
	# Remove temp file
	if OS.get_name() == "Android":
		DirAccess.remove_absolute(temp_path)
	
func showError(msg: String):
	$Output.add_theme_color_override("font_color", Color(1, 0, 0))
	$Output.text = msg
	
func showSuccess(msg: String):
	$Output.add_theme_color_override("font_color", Color(0, 1, 0))
	$Output.text = msg

func nativeFileDialog():
	filedialog = FileDialog.new()
	filedialog.use_native_dialog = true
	filedialog.access = FileDialog.ACCESS_FILESYSTEM
	filedialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	filedialog.filters = ["*.json ; JSON File"]  # File extensions
	filedialog.connect("file_selected", Callable(self, "_on_native_import_file_selected"))
	filedialog.connect("canceled", Callable(self, "_on_native_import_canceled"))
	filedialog.show()

func _on_native_import_file_selected(path: String):
	_on_read_file_picked(path, "")
	filedialog.queue_free()
	
func _on_native_import_canceled():
	filedialog.queue_free()

func _on_donate_button_pressed() -> void:
	$VFlowContainer/DonateContainer/DonateButton.icon = filledHeartIcon
	OS.shell_open("https://ko-fi.com/seppnel")


func _on_close_friends_button_pressed() -> void:
	%SettingsPage/FriendsModal.hide()
	self.show()


func _on_friends_button_pressed() -> void:
	self.hide()
	var modal = get_parent().get_node("FriendsModal")
	modal.update()
	modal.show()
