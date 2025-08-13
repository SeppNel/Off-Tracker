extends Node

const SAVE_PATH = "user://user_cards.save"
const CURR_VER = 3

signal gotCardsChanged

var m_friend_code: int = -1
var m_friends: Dictionary = {}
var m_secret: String = ""
var m_tradeOverride: bool = false
var m_gotCards: Dictionary = {}

func _ready() -> void:
	checkVersion()
	update()

func saveCard(id: int) -> void:
	var sId = str(id)
	if m_gotCards.has(sId):
		m_gotCards[sId] += 1
	else:
		m_gotCards[sId] = 1
	
	save()
	gotCardsChanged.emit()
	
func removeSavedCard(id: int) -> void:
	var sId = str(id)
	m_gotCards[sId] -= 1
	if m_gotCards[sId] < 1:
		m_gotCards.erase(sId)
	
	save()

func readGotCards() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return # Error! We don't have a save to load.

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_line()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	# Get the data from the JSON object
	var data = json.get_data()
	m_gotCards = data["got_cards"]

func getGotCards() -> Dictionary:
	return m_gotCards

func getGotCardsIds() -> Array[int]:
	var gotCardsIds: Array[int] = []
	for card_id in m_gotCards.keys():
		gotCardsIds.append(int(card_id))

	return gotCardsIds

func getSaveJson():
	if not FileAccess.file_exists(SAVE_PATH):
		return ""# Error! We don't have a save to load.

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	return save_file.get_line()

func checkVersion() -> void:
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

func migrateSave1_2() -> void:
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
		
func migrateSave2_3() -> void:
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
	m_gotCards = data["got_cards"]
	
	DirAccess.remove_absolute(SAVE_PATH)
	save()

func save() -> void:
	var save_dict = {
		"version" : CURR_VER,
		"secret": m_secret,
		"friend_code": m_friend_code,
		"tradeOverride": m_tradeOverride,
		"got_cards" : m_gotCards,
		"friends": m_friends,
	}

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)

func setFriendCode(fc: int) -> void:
	m_friend_code = fc
	addFriend(fc, "Myself")
	save()

func addFriend(fc: int, name: String) -> void:
	var fc_str = str(fc)
	if not m_friends.has(fc_str):
		m_friends[fc_str] = name
		save()
		
func deleteFriend(fc: int) -> void:
	var fc_str = str(fc)
	if m_friends.has(fc_str):
		m_friends.erase(fc_str)
		save()

func getFriendName(fc: int) -> String:
	return m_friends[str(fc)]

func setSecret(s) -> void:
	m_secret = s
	save()
	
func setTradeOverride(b: bool) -> void:
	m_tradeOverride = b
	save()
	
func update() -> void:
	readSavedValues()
	readGotCards()
	gotCardsChanged.emit()

func readSavedValues() -> void:
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
