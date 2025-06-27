extends Node2D

@onready var timer_label = $TimerLabel
@onready var countdown_timer = $CountdownTimer
@onready var animation_player = $AnimationPlayer
@onready var entendido_button = $EntendidoButton
@onready var character_node = $AnimationPlayer/CharacterBody2D
@onready var color_rect_node = $AnimationPlayer/ColorRectLegis
@onready var label_node = $AnimationPlayer/LabelLegis
@onready var correcto_button = $CorrectoButton
@onready var correctos_label = $CorrectosLabel
@onready var correcto_button2 = $CorrectoButton2
@onready var correcto_button3 = $CorrectoButton3
@onready var correcto_button4 = $CorrectoButton4
@onready var correcto_button5 = $CorrectoButton5
@onready var equivocado_button = $EquivocadoButton
@onready var continue_button = $ContinueButton
@onready var errorMusci = $error
@onready var clickButton = $clickButton

var db = null
var database : SQLite
var botones_correctos := 0
var botones_presionados := []
var total_time := 60
var game_started := false

func _ready():
	MusicaMenu.juego2()
	continue_button.visible = false
	var sql = "SELECT puntaje FROM jugadores WHERE nombre = ?"
	var result = Jugador.database.query_with_bindings(sql, [Jugador.nombre])
	if result:
		var rows = Jugador.database.query_result
		if rows.size() > 0:
			var puntaje_anterior = int(rows[0]["puntaje"])
			Jugador.puntaje = puntaje_anterior
		else:
			Jugador.puntaje = 0
	else:
		Jugador.puntaje = 0
	Jugador.puntaje += 100
	print("Puntaje cargado y ajustado:", Jugador.puntaje)
	print("Puntaje cargado desde el primer juego:", Jugador.puntaje)
	entendido_button.visible = false
	entendido_button.pressed.connect(_on_entendido_button_pressed)
	continue_button.pressed.connect(_on_continue_pressed) 
	if animation_player.has_animation("Legis-juego2"):
		correcto_button.visible = false
		equivocado_button.visible = false
		animation_player.play("Legis-juego2")
		character_node.visible = true
		color_rect_node.visible = true
		label_node.visible = true
		animation_player.animation_finished.connect(_on_animation_finished)
	else:
		_start_game()

func _start_game():
	game_started = true
	character_node.visible = false
	color_rect_node.visible = false
	label_node.visible = false
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_timer_tick)
	countdown_timer.start()
	_update_timer_label()
	
	# Lista de botones correctos
	var botones = [correcto_button, correcto_button2, correcto_button3, correcto_button4, correcto_button5]
	for boton in botones:
		boton.visible = true
		boton.pressed.connect(_procesar_correcto.bind(boton))
		
	equivocado_button.visible = true
	correcto_button.pressed.connect(_on_correcto_pressed)
	equivocado_button.pressed.connect(_on_equivocado_pressed)

func _on_timer_tick():
	total_time -= 1
	_update_timer_label()
	if total_time <= 0:
		countdown_timer.stop()
		_on_timer_finished()

func _update_timer_label():
	@warning_ignore("integer_division")
	var minutes = total_time / 60
	var seconds = total_time % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_timer_finished():
	var sql = "UPDATE jugadores SET puntaje = ? WHERE nombre = ?"
	Jugador.niveles_completados["nivel2"] = true
	var result = Jugador.database.query_with_bindings(sql, [Jugador.puntaje, Jugador.nombre])
	print("✅ Puntaje actualizado en base de datos:", Jugador.puntaje)
	character_node.visible = true
	color_rect_node.visible = true
	label_node.visible = true
	print("¡Tiempo terminado!")
	for boton in [correcto_button, correcto_button2, correcto_button3, correcto_button4, correcto_button5]:
		boton.visible = false
	equivocado_button.visible = false
	if animation_player.has_animation("Legis_fin"):
		animation_player.play("Legis_fin")

func _on_animation_finished(anim_name: String):
	if anim_name == "Legis-juego2":
		entendido_button.visible = true
	elif anim_name == "Legis_fin":
		MusicaMenu.victoria()
		continue_button.visible = true

func _on_entendido_button_pressed():
	clickButton.play()
	entendido_button.visible = false
	_start_game()

func _on_equivocado_pressed():
	Jugador.puntaje -= 20
	print("Respuesta incorrecta. Puntaje:", Jugador.puntaje)
	errorMusci.play()

func _update_correctos_label():
	correctos_label.text = str(botones_correctos) + "/5"

func _on_correcto_pressed():
	_procesar_correcto(correcto_button)

func _procesar_correcto(boton):
	if boton in botones_presionados:
		return # ya presionado

	botones_presionados.append(boton)
	boton.disabled = true
	boton.visible = false

	Jugador.puntaje += 20
	botones_correctos += 1
	_update_correctos_label()

	# Guardar puntaje en la base de datos
	var sql = "UPDATE jugadores SET puntaje = ? WHERE nombre = ?"
	var result = Jugador.database.query_with_bindings(sql, [Jugador.puntaje, Jugador.nombre])
	print("✅ Puntaje actualizado en base de datos:", Jugador.puntaje)

	if botones_correctos >= 5:
		countdown_timer.stop()
		Jugador.niveles_completados["nivel2"] = true

		character_node.visible = true
		color_rect_node.visible = true
		label_node.visible = true

		print("🎉 ¡Todos los botones correctos fueron presionados!")
		if animation_player.has_animation("Legis_fin"):
			animation_player.play("Legis_fin")
		else:
			print("⚠️ No existe la animación 'Legis_fin'")

func _on_continue_pressed():
	clickButton.play()
	TRANSICION.change_scene_loc("res://Escenas/mapa.tscn")
