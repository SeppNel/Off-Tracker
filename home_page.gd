extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func updateUi():
	$Home/GeneticApex/Packs/MewtwoPack.update()
	$Home/GeneticApex/Packs/CharizardPack.update()
	$Home/GeneticApex/Packs/PikachuPack.update()
	$Home/MythicalIsland/Packs/MewPack.update()
	$Home/SpaceTime/Packs/DialgaPack.update()
	$Home/SpaceTime/Packs/PalkiaPack.update()
