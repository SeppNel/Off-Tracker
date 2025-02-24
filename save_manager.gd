extends Node

const SAVE_PATH = "user://user_cards.save"
const CURR_VER = 2

static var m_friend_code: int = -1
static var m_friends: Dictionary = {}
static var m_secret: String = ""

static func _static_init() -> void:
	checkVersion()
	update()

static func saveCard(id: int):
	var sId = str(id)
	var gotCards = getGotCards()
	if gotCards.has(sId):
		gotCards[sId] += 1
	else:
		gotCards[sId] = 1
	
	save(gotCards)
	
static func removeSavedCard(id: int):
	var sId = str(id)
	var gotCards = getGotCards()
	gotCards[sId] -= 1
	if gotCards[sId] < 1:
		gotCards.erase(sId)
	
	save(gotCards)

static func getGotCards():
	if not FileAccess.file_exists(SAVE_PATH):
		return {}# Error! We don't have a save to load.

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	# Get the data from the JSON object
	var data = json.get_data()

	return data["got_cards"]

static func getGotCardsIds():
	if not FileAccess.file_exists(SAVE_PATH):
		return []# Error! We don't have a save to load.

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	# Get the data from the JSON object
	var data = json.get_data()

	var gotCards = []
	for card_id in data["got_cards"].keys():
		gotCards.append(int(card_id))

	return gotCards

static func getSaveJson():
	if not FileAccess.file_exists(SAVE_PATH):
		return ""# Error! We don't have a save to load.

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	return save_file.get_line()
	
static func checkVersion():
	if not FileAccess.file_exists(SAVE_PATH):
		return #Error! We don't have a save

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	# Get the data from the JSON object
	var data = json.get_data()
	if not data.has("version"):
		migrateSave()

static func migrateSave():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	# Get the data from the JSON object
	var data = json.get_data()
	
	DirAccess.remove_absolute(SAVE_PATH)
	
	for card in data["got_cards"]:
		saveCard(card)

static func save(gotCards):
	var save_dict = {
		"got_cards" : gotCards,
		"friend_code": m_friend_code,
		"secret": m_secret,
		"friends": m_friends,
		"version" : CURR_VER,
	}

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)

static func readFriendCode() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		return -1

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()

	var json = JSON.new()
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	var data = json.get_data()
	return data["friend_code"]
	
static func readFriends() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()

	var json = JSON.new()
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}

	var data = json.get_data()
	return data["friends"]
	
static func readSecret() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return ""

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()

	var json = JSON.new()
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return ""

	var data = json.get_data()
	return data["secret"]

static func setFriendCode(fc: int) -> void:
	m_friend_code = fc
	save(getGotCards())

static func addFriend(fc: int, name: String) -> void:
	var fc_str = str(fc)
	if not m_friends.has(fc_str):
		m_friends[fc_str] = name
		save(getGotCards())
		
static func deleteFriend(fc: int) -> void:
	var fc_str = str(fc)
	if m_friends.has(fc_str):
		m_friends.erase(fc_str)
		save(getGotCards())


static func getFriendName(fc: int) -> String:
	return m_friends[str(fc)]

static func setSecret(s) -> void:
	m_secret = s
	save(getGotCards())
	
static func update() -> void:
	m_friend_code = readFriendCode()
	m_friends = readFriends()
	m_secret = readSecret()
