extends Node
	
static func saveNewCard(id: int):
	var gotCards = getGotCards()
	gotCards.append(id)
	
	var save_dict = {
		"got_cards" : gotCards,
	}

	var save_file = FileAccess.open("user://user_cards.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)
	
static func removeSavedCard(id: int):
	var gotCards = getGotCards()
	gotCards.erase(id)
	
	var save_dict = {
		"got_cards" : gotCards,
	}

	var save_file = FileAccess.open("user://user_cards.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)

static func getGotCards():
	if not FileAccess.file_exists("user://user_cards.save"):
		return []# Error! We don't have a save to load.

	var save_file = FileAccess.open("user://user_cards.save", FileAccess.READ)
	var json_string = save_file.get_line()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	# Get the data from the JSON object
	var data = json.get_data()

	var gotCards = []
	for card_id in data["got_cards"]:
		gotCards.append(int(card_id))
	
	return gotCards
