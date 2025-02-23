extends PanelContainer

const SaveManager = preload("res://save_manager.gd")

func update():
	clear()
	loadFriends()

func clear():
	for child in $VFlowContainer.get_children():
		child.queue_free()

func loadFriends() -> void:
	var friends = SaveManager.m_friends
	for friend in friends:
		var panelCont = PanelContainer.new()
		panelCont.add_theme_stylebox_override("panel", load("res://themes/manageFriendsPanel.tres"))
		var hBoxCont = HBoxContainer.new()
		var label = Label.new()
		label.text = friends[friend] + " (" + friend + ")"
		label.add_theme_font_size_override("font_size", 60)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var button = Button.new()
		button.text = "Remove"
		button.custom_minimum_size = Vector2(300, 150)
		button.add_theme_font_size_override("font_size", 60)
		button.connect("pressed", Callable(_on_delete_friend_pressed).bind(int(friend)))
		hBoxCont.add_child(label)
		hBoxCont.add_child(button)
		panelCont.add_child(hBoxCont)
		$VFlowContainer.add_child(panelCont)

func _on_delete_friend_pressed(fc: int):
	SaveManager.deleteFriend(fc)
	update()
