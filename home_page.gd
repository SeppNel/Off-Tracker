extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func updateUi():
	$Home/GeneticApex/Packs/MewtwoPack.updateNumberofCards()
	$Home/GeneticApex/Packs/CharizardPack.updateNumberofCards()
	$Home/GeneticApex/Packs/PikachuPack.updateNumberofCards()
	$Home/MythicalIsland/Packs/MewPack.updateNumberofCards()
	$Home/SpaceTime/Packs/DialgaPack.updateNumberofCards()
	$Home/SpaceTime/Packs/PalkiaPack.updateNumberofCards()
