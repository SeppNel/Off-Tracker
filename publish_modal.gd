extends PanelContainer

const SaveManager = preload("res://static/save_manager.gd")
var DbManager = preload("res://static/database.gd")

const BASE_URL = "http://pertusa.myftp.org/.resources/php/off/"
var wantCards = []

func _on_accept_publish_pressed() -> void:
	if wantCards.is_empty():
		return
		
	var validRarities = wantCardsRarities()
	var gotCards = SaveManager.getGotCards()
	var tradeableCards = DbManager.getTradeableCardsIds()
	var offerCards = []
	
	for card in gotCards:
		if not int(card) in tradeableCards:
			continue
		
		var count = gotCards[card]
		if count > 1:
			var rarity = DbManager.getCardRarity(int(card))
			if rarity in validRarities:
				offerCards.append(int(card))
				
	sendRestAPI(offerCards)
	closeModal()

func wantCardsRarities():
	var r = []
	for card in wantCards:
		r.append(DbManager.getCardRarity(card))
		
	return r

func sendRestAPI(offer) -> void:
	var data = {
		"friend_code": SaveManager.m_friend_code,
		"secret": SaveManager.m_secret,
		"wants": wantCards,
		"has": offer,
	}
	
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	
	var url = BASE_URL + "friend_set.php"
	
	var request = HTTPRequest.new()
	request.request_completed.connect(request.queue_free.unbind(4))
	add_child(request)
	request.request(url, headers, HTTPClient.METHOD_POST, json)

func _on_cancel_publish_pressed() -> void:
	closeModal()

func addWantCard(id: int) -> bool:
	if id in wantCards:
		removeWantCard(id)
		return true
		
	if wantCards.size() + 1 > 6:
		return false
		
	wantCards.append(id)
	return true

func removeWantCard(id: int):
	wantCards.erase(id)
	
func closeModal() -> void:
	wantCards = []
	self.hide()
	%FriendsPage/PublishConfirmContainer.hide()
	%FriendsPage/ScrollContainer/HFlowContainer.show()
	if SaveManager.m_friend_code != -1:
		%FriendsPage/PublishContainer.show()
