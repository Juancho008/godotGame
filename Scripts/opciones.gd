extends Control
@onready var clickButton = $clickButton
func _on_volver_pressed() -> void:
	#get_tree().change_scene_to_file("res://Escenas/menu.tscn")
	clickButton.play()
	TRANSICION.change_scene_loc("res://Escenas/menu.tscn")
