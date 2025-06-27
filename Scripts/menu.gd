extends Control
@onready var clickButton = $clickButton

func _ready():
	MusicaMenu.menu()
	
func _on_jugar_pressed() -> void:
	clickButton.play()
	TRANSICION.change_scene_loc("res://Escenas/teclado.tscn")

func _on_opciones_pressed() -> void:
	clickButton.play()
	TRANSICION.change_scene_loc("res://Escenas/settings_menu.tscn")
	
func _on_ranking_pressed() -> void:
	clickButton.play()
	TRANSICION.change_scene_loc("res://Escenas/ranking.tscn")
	
func _on_salir_pressed() -> void:
	clickButton.play()
	get_tree().quit()
