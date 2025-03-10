extends VBoxContainer

const SaveManager = preload("res://static/save_manager.gd")
const UuidManager = preload('res://static/uuid.gd')
const FriendScene = preload("res://friend.tscn")

const BASE_URL = "http://pertusa.myftp.org/.resources/php/off/"

var m_onlyMissing: bool = false
var m_gotCards: Array[int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveManager.m_friend_code == -1:
		$PublishContainer.hide()
		$NoCodeAlert.show()
		
	update()

func update() -> void:
	clear()
	m_gotCards = SaveManager.getGotCardsIds()
	fillFriends()

func fillFriends() -> void:
	var friends = SaveManager.m_friends
	for id_str in friends:
		var url = BASE_URL + "friend_get.php?friend_code=" + id_str
		var request = HTTPRequest.new()
		request.request_completed.connect(_on_fc_get_request_completed)
		request.request_completed.connect(request.queue_free.unbind(4))
		add_child(request)
		request.request(url)

func _on_fc_get_request_completed(result, response_code, headers, body):
	var content = body.get_string_from_utf8()
	if content == "Error":
		print("Friend error")
		return
	var json = JSON.parse_string(content)
	var fc: int = json["friend_code"]
	var name: String = SaveManager.getFriendName(fc)
	
	var friend = FriendScene.instantiate()
	friend.setName(name + " (" + str(fc) + ")")
	
	for card: int in json["wants"]:
		friend.addMissingCard(card)
		
	for card: int in json["has"]:
		if m_onlyMissing:
			if card not in m_gotCards:
				friend.addOfferCard(card)
		else:
			friend.addOfferCard(card)
	
	%FriendsContainer.add_child(friend)
	var marginTop = Control.new()
	marginTop.custom_minimum_size = Vector2(1080, 50)
	marginTop.mouse_filter = MOUSE_FILTER_IGNORE
	%FriendsContainer.add_child(marginTop)

func clear():
	for child in %FriendsContainer.get_children():
		child.queue_free()

func _on_code_button_pressed() -> void:
	var secret = SaveManager.m_secret
	if secret == "":
		secret = UuidManager.v4()
		SaveManager.setSecret(secret)
	
	var url = BASE_URL + "create_friend_code.php?secret=" + secret
	var request = HTTPRequest.new()
	request.request_completed.connect(_on_create_request_completed)
	request.request_completed.connect(request.queue_free.unbind(4))
	add_child(request)
	request.request(url)

func _on_create_request_completed(result, response_code, headers, body):
	var my_fc = body.get_string_from_utf8()
	if my_fc == "Error" or my_fc == "":
		return
	SaveManager.setFriendCode(int(my_fc))
	get_parent().get_node("SettingsPage/Settings/VFlowContainer/FCContainer/FriendCodeLabel").text = "Friend Code: " + my_fc
	$NoCodeAlert.hide()
	$PublishContainer.show()


func _on_add_button_pressed() -> void:
	$ScrollContainer.scroll_vertical = 0
	$ScrollContainer/AddModal/VFlowContainer/FcInput.text = ""
	$ScrollContainer/AddModal/VFlowContainer/FNameInput.text = ""
	$ScrollContainer/AddModal.show()


func _on_accept_add_pressed() -> void:
	var fc_string: String = $ScrollContainer/AddModal/VFlowContainer/FcInput.text
	var name: String = $ScrollContainer/AddModal/VFlowContainer/FNameInput.text
	if !fc_string.is_valid_int() or name == "" or len(name) > 15:
		return
	var fc: int = int(fc_string)
	SaveManager.addFriend(fc, name)
	$ScrollContainer/AddModal.hide()
	update()


func _on_cancel_add_pressed() -> void:
	$ScrollContainer/AddModal.hide()


func _on_publish_button_pressed() -> void:
	$ScrollContainer.scroll_vertical = 0
	$ScrollContainer/HFlowContainer.hide()
	%FriendsPage/PublishContainer.hide()
	
	$ScrollContainer/PublishModal/VBoxContainer/CardList.update()
	
	$ScrollContainer/PublishModal.show()
	%FriendsPage/PublishConfirmContainer.show()


func _on_only_missing_check_pressed() -> void:
	m_onlyMissing = !m_onlyMissing
	update()
