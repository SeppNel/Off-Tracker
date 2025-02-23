extends HBoxContainer

func _on_home_pressed() -> void:
	%CardPage.hide()
	%SettingsPage.hide()
	%FriendsPage.hide()
	
	%HomePage.updateUi()
	%HomePage.show()

func _on_cards_pressed() -> void:
	%HomePage.hide()
	%SettingsPage.hide()
	%FriendsPage.hide()
	
	%CardPage.show()

func _on_settings_pressed() -> void:
	%CardPage.hide()
	%HomePage.hide()
	%FriendsPage.hide()
	%SettingsPage/FriendsModal.hide()
	
	%SettingsPage/Settings.show()
	%SettingsPage/Settings/Output.text = ""
	%SettingsPage.show()


func _on_friends_pressed() -> void:
	%CardPage.hide()
	%HomePage.hide()
	%SettingsPage.hide()
	
	%FriendsPage.update()
	%FriendsPage.show()
