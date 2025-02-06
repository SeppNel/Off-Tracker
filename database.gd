extends Node

var db : SQLite = null
const verbosity_level : int = SQLite.QUIET
const db_name := "res://data/db.sqlite"

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	db = SQLite.new()
	db.path = db_name
	db.verbosity_level = verbosity_level
	db.read_only = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func getAllCards():
	db.open_db()

	var select_condition : String = ""
	var selected_array : Array = db.select_rows("cards", select_condition, ["*"])

	db.close_db()
	return selected_array
	
func getGeneticApexCards(order: String = "c.id ASC"):
	db.open_db()

	db.query("
		SELECT c.*
		FROM cards c
		JOIN packs p ON c.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 1

		UNION

		SELECT c.*
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 1
		
		UNION

		SELECT * FROM cards where id = 283 
		ORDER BY " + order + ";") # Add Mew
	
	db.close_db()
	return db.query_result_by_reference
	
func getMythicalIslandsCards(order: String = "c.id ASC"):
	db.open_db()

	db.query("
		SELECT c.*
		FROM cards c
		JOIN packs p ON c.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 2

		UNION

		SELECT c.*
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 2
		  AND c.id != 218
		ORDER BY " + order + ";") # Remove Old Amber
	
	db.close_db()
	return db.query_result_by_reference
	
func getPromoCards():
	db.open_db()

	db.query("
		SELECT *
		FROM cards
		WHERE rarity = 0;")
	
	db.close_db()
	return db.query_result_by_reference
	
func getSpaceTimeCards(order: String = "c.id ASC"):
	db.open_db()

	db.query("
		SELECT c.*
		FROM cards c
		JOIN packs p ON c.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 3

		UNION

		SELECT c.*
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 3
		ORDER BY " + order + ";")
	
	db.close_db()
	return db.query_result_by_reference

func getCardsIdFromPack(pack: int):
	db.open_db()
	
	var query = "
		SELECT DISTINCT c.id
		FROM cards c
		LEFT JOIN card_packs cp ON c.id = cp.card_id
		WHERE c.pack = ? OR cp.pack = ?;"

	db.query_with_bindings(query, [pack, pack])
	db.close_db()
	
	var result = db.query_result_by_reference
	var id_array = []
	for item in result:
		id_array.append(item["id"])
	
	return id_array
	
func countRarityCardsFromPack(pack: int, r: int):
	db.open_db()
	
	var query = "
		SELECT COUNT(c.id) AS count
		FROM cards c
		LEFT JOIN card_packs cp ON c.id = cp.card_id
		WHERE (c.pack = ? OR cp.pack = ?) AND c.rarity = ?;"

	db.query_with_bindings(query, [pack, pack, r])
	db.close_db()
	
	return db.query_result[0]["count"]

func getPacksOfCard(card: int):
	db.open_db()
	
	var query = "
		SELECT pack
		FROM cards
		WHERE id = ? AND is_multipack = 0

		UNION

		SELECT pack
		FROM card_packs
		where card_id = ?;"

	db.query_with_bindings(query, [card, card])
	db.close_db()
	
	var arr = []
	for item in db.query_result_by_reference:
		arr.append(item["pack"])
	
	return arr
	
func getCardRarity(card: int):
	db.open_db()
	
	var query = "
		SELECT rarity
		FROM cards
		WHERE id = ?;"

	db.query_with_bindings(query, [card])
	db.close_db()
	
	return db.query_result[0]["rarity"]
	
func getCardName(card: int):
	db.open_db()
	
	var query = "
		SELECT name
		FROM cards
		WHERE id = ?;"

	db.query_with_bindings(query, [card])
	db.close_db()
	
	return db.query_result[0]["name"]
