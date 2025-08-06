extends Node

const VERBOSITY_LEVEL : int = SQLite.QUIET
const DB_NAME := "res://data/db.sqlite"
const DEFAULT_LTP : int = 12 # Latest Tradeable Pack
const DEFAULT_LC : int = 9 # Latest Collection

var db : SQLite = null
var latest_tradeable_pack : int = DEFAULT_LTP
var latest_collection : int = DEFAULT_LC

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db = SQLite.new()
	db.path = DB_NAME
	db.verbosity_level = VERBOSITY_LEVEL
	db.read_only = true
	db.open_db()
	updateLatestTradeable()
	
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
	
func getGeneticApexCards(order: String = "c.id ASC"):
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
	
func getMythicalIslandsCards(order: String = "c.id ASC"):
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
	
func getPromoCards():
	db.query("
		SELECT *
		FROM cards
		WHERE rarity = 0;")
	
	return db.query_result_by_reference
	
func getSpaceTimeCards(order: String = "c.id ASC"):
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
	
func getTradeableCards():
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
	
func getTradeableCardsIds():
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
	
	var result = db.query_with_bindings(query, [latest_tradeable_pack, latest_collection])
	var id_array = []
	for item in result:
		id_array.append(item["id"])
	
	return id_array

func getTriumphantLightCards(order: String = "c.id ASC"):
	db.query("
		SELECT c.*
		FROM cards c
		WHERE c.pack = 7
		ORDER BY " + order + ";")
	
	return db.query_result_by_reference
	
func getShiningRevelryCards(order: String = "c.id ASC"):
	db.query("
		SELECT c.*
		FROM cards c
		WHERE c.pack = 8
		ORDER BY " + order + ";")
	
	return db.query_result_by_reference
	
func getCelestialGuardiansCards(order: String = "c.id ASC"):
	db.query("
		SELECT c.*
		FROM cards c
		JOIN packs p ON c.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 6

		UNION

		SELECT c.*
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 6
		ORDER BY " + order + ";")
	
	return db.query_result_by_reference

func getExtraCrisisCards(order: String = "c.id ASC"):
	db.query("
		SELECT c.*
		FROM cards c
		WHERE c.pack = 11
		ORDER BY " + order + ";")
	
	return db.query_result_by_reference
	
func getEeveeGroveCards(order: String = "c.id ASC"):
	db.query("
		SELECT c.*
		FROM cards c
		WHERE c.pack = 12
		ORDER BY " + order + ";")
	
	return db.query_result_by_reference

func getWisdomSeaSkyCards(order: String = "c.id ASC"):
	db.query("
		SELECT c.*
		FROM cards c
		JOIN packs p ON c.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 9

		UNION

		SELECT c.*
		FROM cards c
		JOIN card_packs cp ON c.id = cp.card_id
		JOIN packs p ON cp.pack = p.id
		JOIN collections col ON p.collection = col.id
		WHERE col.id = 9
		ORDER BY " + order + ";")
	
	return db.query_result_by_reference
