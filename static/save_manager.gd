extends Node

const SAVE_PATH = "user://user_cards.save"
const CURR_VER = 3

static var m_friend_code: int = -1
static var m_friends: Dictionary = {}
static var m_secret: String = ""
static var m_tradeOverride: bool = false

static func _static_init() -> void:
	checkVersion()
	update()

static func saveCard(id: int) -> void:
	var sId = str(id)
	var gotCards = getGotCards()
	if gotCards.has(sId):
		gotCards[sId] += 1
	else:
		gotCards[sId] = 1
	
	save(gotCards)
	
static func removeSavedCard(id: int) -> void:
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

static func getGotCardsIds() -> Array[int]:
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

	var gotCards: Array[int] = []
	for card_id in data["got_cards"].keys():
		gotCards.append(int(card_id))

	return gotCards

static func getSaveJson():
	if not FileAccess.file_exists(SAVE_PATH):
		return ""# Error! We don't have a save to load.

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	return save_file.get_line()

static func checkVersion() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return #Error! We don't have a save
	
	# Creates the helper class to interact with JSON
	var json = JSON.new()
	var version: int = 0

	while version != CURR_VER:
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = save_file.get_line()
		save_file.close()

		# Check if there is any error while parsing the JSON string
		if not json.parse(json_string) == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

		# Get the data from the JSON object
		var data = json.get_data()
		if not data.has("version"):
			migrateSave1_2()
			version = 1
		else:
			version = data["version"]
			if version == 2:
				migrateSave2_3()

static func migrateSave1_2() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()
	save_file.close()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	# Get the data from the JSON object
	var data = json.get_data()
	
	DirAccess.remove_absolute(SAVE_PATH)
	
	for card: int in data["got_cards"]:
		saveCard(card)
		
static func migrateSave2_3() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()
	save_file.close()
	
	var json = JSON.new()
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	var data = json.get_data()
	m_friend_code = int(data["friend_code"])
	m_friends = data["friends"]
	m_secret = data["secret"]
	
	DirAccess.remove_absolute(SAVE_PATH)
	save(data["got_cards"])

static func save(gotCards) -> void:
	var save_dict = {
		"version" : CURR_VER,
		"secret": m_secret,
		"friend_code": m_friend_code,
		"tradeOverride": m_tradeOverride,
		"got_cards" : gotCards,
		"friends": m_friends,
	}

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)

static func setFriendCode(fc: int) -> void:
	m_friend_code = fc
	addFriend(fc, "Myself")
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
	
static func setTradeOverride(b: bool) -> void:
	m_tradeOverride = b
	save(getGotCards())
	
static func update() -> void:
	readSavedValues()

static func readSavedValues() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()
	save_file.close()
	
	var json = JSON.new()
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	var data = json.get_data()
	m_friend_code = int(data["friend_code"])
	m_friends = data["friends"]
	m_secret = data["secret"]
	m_tradeOverride = bool(data["tradeOverride"])
