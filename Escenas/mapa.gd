extends Control

@onready var boton_nivel_2 = $segundonivel
@onready var boton_nivel_3 = $tercernivel
@onready var boton_nivel_4 = $cuartonivel
@onready var clickButton = $clickButton

func _on_volver_pressed() -> void:
	TRANSICION.change_scene_loc("res://Escenas/menu.tscn")
	clickButton.play()
	
func _on_primernivel_pressed() -> void:
	TRANSICION.change_scene_loc("res://Escenas/intro-primer-juego.tscn")
	clickButton.play()
	
func _on_segundonivel_pressed() -> void:
	TRANSICION.change_scene_loc("res://Escenas/juego_2.tscn")
	clickButton.play()
	
func _on_tercernivel_pressed() -> void:
	TRANSICION.change_scene_loc("res://Escenas/juego_3.tscn")
	clickButton.play()
	
func _on_cuartonivel_pressed() -> void:
	TRANSICION.change_scene_loc("res://Escenas/juego_4.tscn")
	clickButton.play()
	
func _ready():
	MusicaMenu.menu()
	boton_nivel_2.disabled = not Jugador.niveles_completados["nivel1"]
	boton_nivel_3.disabled = not Jugador.niveles_completados["nivel2"]
	boton_nivel_4.disabled = not Jugador.niveles_completados["nivel3"]
