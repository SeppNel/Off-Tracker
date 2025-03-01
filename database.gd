extends Node

static var db : SQLite = null
const verbosity_level : int = SQLite.QUIET
const db_name := "res://data/db.sqlite"

# Called when the node enters the scene tree for the first time.
static func _static_init() -> void:
	db = SQLite.new()
	db.path = db_name
	db.verbosity_level = verbosity_level
	db.read_only = true
	db.open_db()

static func getAllCards():
	var select_condition : String = ""
	var selected_array : Array = db.select_rows("cards", select_condition, ["*"])

	return selected_array
	
static func getGeneticApexCards(order: String = "c.id ASC"):
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
	
	return db.query_result_by_reference
	
static func getMythicalIslandsCards(order: String = "c.id ASC"):
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
	
	return db.query_result_by_reference
	
static func getPromoCards():
	db.query("
		SELECT *
		FROM cards
		WHERE rarity = 0;")
	
	return db.query_result_by_reference
	
static func getSpaceTimeCards(order: String = "c.id ASC"):
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
	
	return db.query_result_by_reference

static func getCardsIdFromPack(pack: int):
	var query = "
		SELECT DISTINCT c.id
		FROM cards c
		LEFT JOIN card_packs cp ON c.id = cp.card_id
		WHERE c.pack = ? OR cp.pack = ?;"

	db.query_with_bindings(query, [pack, pack])
	
	var result = db.query_result_by_reference
	var id_array = []
	for item in result:
		id_array.append(item["id"])
	
	return id_array
	
static func countRarityCardsFromPack(pack: int, r: int):
	var query = "
		SELECT COUNT(c.id) AS count
		FROM cards c
		LEFT JOIN card_packs cp ON c.id = cp.card_id
		WHERE (c.pack = ? OR cp.pack = ?) AND c.rarity = ?;"

	db.query_with_bindings(query, [pack, pack, r])
	
	return db.query_result[0]["count"]

static func getPacksOfCard(card: int):
	var query = "
		SELECT pack
		FROM cards
		WHERE id = ? AND is_multipack = 0

		UNION

		SELECT pack
		FROM card_packs
		where card_id = ?;"

	db.query_with_bindings(query, [card, card])
	
	var arr = []
	for item in db.query_result_by_reference:
		arr.append(item["pack"])
	
	return arr
	
static func getCardRarity(card: int):
	var query = "
		SELECT rarity
		FROM cards
		WHERE id = ?;"

	db.query_with_bindings(query, [card])
	
	return db.query_result[0]["rarity"]
	
static func getCardName(card: int):
	var query = "
		SELECT name
		FROM cards
		WHERE id = ?;"

	db.query_with_bindings(query, [card])
	
	return db.query_result[0]["name"]

static func search(n: String, t: int, s: int, r: int, p: int, w: int, order: String = "c.id ASC"):
	n += "%"
	var query = "
		SELECT id, image
		FROM cards c
		WHERE name LIKE ?
		AND (? IS 0 OR type = ?)
		AND (? IS 0 OR card_type = ?)
		AND (? IS 0 OR rarity = ?)
		AND (? IS 0 OR pack = ?)
		AND (? IS 0 OR weakness = ?)
		ORDER BY " + order + ";"
	
	db.query_with_bindings(query, [n, t, t, s, s, r, r, p, p, w, w])
	
	return db.query_result_by_reference

static func getCard(id: int):
	var query = "
		SELECT *
		FROM cards
		WHERE id = ?;"

	db.query_with_bindings(query, [id])
	
	return db.query_result[0]
	
static func getTradeableCards():
	db.query("
		SELECT * 
		FROM cards 
		WHERE rarity > 0 AND rarity < 6
		AND pack in (1,2,3,4,5,6)

		UNION

		SELECT DISTINCT c.*
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id != 4
		AND rarity > 0 and rarity < 6;")
	
	return db.query_result_by_reference
	
static func getTradeableCardsIds():
	db.query("
		SELECT id 
		FROM cards 
		WHERE rarity > 0 AND rarity < 6
		AND pack in (1,2,3,4,5,6)

		UNION

		SELECT DISTINCT c.id
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id != 4
		AND rarity > 0 and rarity < 6;")
	
	var result = db.query_result_by_reference
	var id_array = []
	for item in result:
		id_array.append(item["id"])
	
	return id_array

static func getTriumphantLightCards(order: String = "c.id ASC"):
	db.query("
		SELECT c.*
		FROM cards c
		WHERE c.pack = 7
		ORDER BY " + order + ";")
	
	return db.query_result_by_reference
