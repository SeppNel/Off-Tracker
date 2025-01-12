extends HFlowContainer

var Database = preload("res://database.gd")
var CardScene = preload("res://card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var db_manager = Database.new()
	var cardList = db_manager.getAllCards()
	print(cardList)
	var i = 0
	while i < 50:
		var img = load("res://img/cards/default.png")
		var cs = CardScene.instantiate()
		cs.custom_minimum_size.x = 300
		cs.custom_minimum_size.y = 400
		cs.get_node("Card").scale = Vector2(0.7, 0.7)
		add_child(cs)
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
