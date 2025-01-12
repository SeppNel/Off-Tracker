extends Node

var db : SQLite = null

const verbosity_level : int = SQLite.VERBOSE

var db_name := "res://data/db.sqlite"

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	db = SQLite.new()
	db.path = db_name
	db.verbosity_level = verbosity_level
	db.read_only = true

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func getAllCards():
	db.open_db()

	var select_condition : String = ""
	var selected_array : Array = db.select_rows("cards", select_condition, ["*"])

	db.close_db()
	return selected_array

func example_of_read_only_database():
	# Select all the creatures
	var select_condition : String = ""
	var selected_array : Array = db.select_rows("creatures", select_condition, ["*"])
	print("condition: " + select_condition)
	print("result: {0}".format([str(selected_array)]))

	# Select all the creatures that start with the letter 'b'
	select_condition = "name LIKE 'b%'"
	selected_array = db.select_rows("creatures", select_condition, ["name"])
	print("condition: " + select_condition)
	print("Following creatures start with the letter 'b':")
	for row in selected_array:
		print("* " + row["name"])

	# Get the experience you would get by kiling a mimic.
	select_condition = "name = 'mimic'"
	selected_array = db.select_rows("creatures", select_condition, ["experience"])
	print("Killing a mimic yields " + str(selected_array[0]["experience"]) + " experience points!")

	# Close the current database
	db.close_db()
