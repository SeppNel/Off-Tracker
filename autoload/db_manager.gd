extends Node

const VERBOSITY_LEVEL: int = SQLite.QUIET
const DB_NAME: String = "res://data/db.sqlite"

var db: SQLite = null
var DEFAULT_LTP: int # Latest Tradeable Pack
var DEFAULT_LC: int # Latest Collection
var latest_tradeable_pack: int
var latest_collection: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db = SQLite.new()
	db.path = DB_NAME
	db.verbosity_level = VERBOSITY_LEVEL
	db.read_only = true
	db.open_db()
	DEFAULT_LC = default_lc()
	DEFAULT_LTP = default_ltp()
	updateLatestTradeable()
	
func default_lc() -> int:
	db.query("SELECT MAX(id) as id FROM collections;")
	return db.query_result_by_reference[0]["id"]

func default_ltp() -> int:
	var query: String = "
		SELECT MAX(id) as id
		FROM packs
		WHERE collection = ?"
		
	db.query_with_bindings(query, [DEFAULT_LC - 1])
	return db.query_result_by_reference[0]["id"]

func updateLatestTradeable():
	if not SaveManager.m_tradeOverride:
		latest_tradeable_pack = DEFAULT_LTP
		latest_collection = DEFAULT_LC
		return
	
	db.query("
		SELECT COUNT(id) AS count
		FROM packs 
		WHERE collection = (SELECT MAX(id) FROM collections);")
	
	var packs_in_latest_col: int = db.query_result_by_reference[0]["count"]
	latest_tradeable_pack += packs_in_latest_col
	latest_collection = DEFAULT_LC + 1

func getAllCards():
	db.query("SELECT * FROM cards;")
	return db.query_result_by_reference
	
func getPromoCards():
	db.query("
		SELECT *
		FROM cards
		WHERE rarity = 0;")
	
	return db.query_result_by_reference

func getCardsIdFromPack(pack: int):
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
	
func countRarityCardsFromPack(pack: int, r: int):
	var query = "
		SELECT COUNT(c.id) AS count
		FROM cards c
		LEFT JOIN card_packs cp ON c.id = cp.card_id
		WHERE (c.pack = ? OR cp.pack = ?) AND c.rarity = ?;"

	db.query_with_bindings(query, [pack, pack, r])
	
	return db.query_result[0]["count"]

func getPacksOfCard(card: int):
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
	
func getCardRarity(card: int):
	var query = "
		SELECT rarity
		FROM cards
		WHERE id = ?;"

	db.query_with_bindings(query, [card])
	
	return db.query_result[0]["rarity"]
	
func getCardName(card: int):
	var query = "
		SELECT name
		FROM cards
		WHERE id = ?;"

	db.query_with_bindings(query, [card])
	
	return db.query_result[0]["name"]

func search(n: String, t: int, s: int, r: int, p: int, w: int, order: String = "c.id ASC"):
	n = "'" + n + "%'"
	var format_query = "
		SELECT id, image
		FROM cards c
		WHERE name LIKE {name}
		AND ({type} IS 0 OR type = {type})
		AND ({stage} IS 0 OR card_type = {stage})
		AND ({rarity} IS 0 OR rarity = {rarity})
		AND ({pack} IS 0 OR pack = {pack})
		AND ({weak} IS 0 OR weakness = {weak})
		
		UNION

		SELECT c.id, c.image
		FROM card_packs cp
		JOIN cards c ON cp.card_id = c.id
		WHERE cp.pack IN (
			SELECT id 
			FROM packs 
			WHERE collection = (SELECT collection FROM packs WHERE id = {pack})
		)
		AND c.name LIKE {name}
		AND ({type} IS 0 OR c.type = {type})
		AND ({stage} IS 0 OR c.card_type = {stage})
		AND ({rarity} IS 0 OR c.rarity = {rarity})
		AND ({weak} IS 0 OR c.weakness = {weak})
		
		ORDER BY " + order + ";"
		
	var query = format_query.format({"name": n, "type": t, "stage": s, "pack": p, "rarity": r, "weak": w})
	
	db.query(query)
	return db.query_result_by_reference

func getCard(id: int):
	var query = "
		SELECT *
		FROM cards
		WHERE id = ?;"

	db.query_with_bindings(query, [id])
	
	return db.query_result[0]
	
func getTradeableCards() -> Array[Dictionary]:
	var query = "
		SELECT * 
		FROM cards 
		WHERE rarity > 0 AND rarity < 6
		AND pack <= ? AND is_multipack = 0

		UNION

		SELECT DISTINCT c.*
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id != ?
		AND rarity > 0 and rarity < 6;"
		
	db.query_with_bindings(query, [latest_tradeable_pack, latest_collection])
	
	return db.query_result_by_reference
	
func getTradeableCardsIds() -> Array[int]:
	var query = "
		SELECT id 
		FROM cards 
		WHERE rarity > 0 AND rarity < 6
		AND pack <= ? AND is_multipack = 0

		UNION

		SELECT DISTINCT c.id
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id != ?
		AND rarity > 0 and rarity < 6;"
		
	db.query_with_bindings(query, [latest_tradeable_pack, latest_collection])
	
	var result = db.query_result_by_reference
	var id_array: Array[int] = []
	for item in result:
		id_array.append(item["id"])
	
	return id_array

func getCollectionName(col: int) -> String:
	var query: String = "
		SELECT name
		FROM collections
		WHERE id = ?;"
	
	db.query_with_bindings(query, [col])
	return db.query_result_by_reference[0]["name"]

func getCollections() -> Array[Dictionary]:
	db.query("
		SELECT *
		FROM collections;")
	
	return db.query_result_by_reference

func getCardsInCollection(col: int, order: String = "c.id ASC") -> Array[Dictionary]:
	var query: String = "
		SELECT c.*
		FROM cards c
		JOIN packs p ON c.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = ?

		UNION

		SELECT c.*
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = ?
		ORDER BY " + order + ";"
		
	db.query_with_bindings(query, [col, col])
	return db.query_result_by_reference

func getPacks() -> Array[Dictionary]:
	db.query("
		SELECT *
		FROM packs;")
	
	return db.query_result_by_reference
