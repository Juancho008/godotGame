extends Node2D

@onready var timer_label = $TimerLabel
@onready var countdown_timer = $CountdownTimer
@onready var animation_player = $AnimationPlayer
@onready var character_node = $AnimationPlayer/CharacterBody2D
@onready var color_rect_node = $AnimationPlayer/ColorRectLegis
@onready var label_node = $AnimationPlayer/LabelLegis
@onready var continue_button = $ContinueButton
@onready var nervios_button = $nerviosButton
@onready var votamos = $AnimationPlayer/votamos
@onready var label_votamos = $AnimationPlayer/LabelVotamos
@onready var cuadro_votamos = $AnimationPlayer/cuadroVotamos
@onready var aprobado_button = $AnimationPlayer/Aprobado
@onready var reprobado_button = $AnimationPlayer/Reprobado
@onready var penalizacion_label = $PenalizacionLabel
@onready var aplausos = $aplausos
@onready var clickButton = $clickButton

var db = null
var database : SQLite
var total_time := 60
var game_started := false
var ya_repetido := false
var auto_penalizacion_timer := Timer.new()
var penalizacion_visual_timer := Timer.new()
var penalizacion_visual_time := 3

func _ready():
	MusicaMenu.juego3()
	add_child(penalizacion_visual_timer)
	penalizacion_visual_timer.wait_time = 1.0
	penalizacion_visual_timer.timeout.connect(_on_penalizacion_visual_tick)
	add_child(auto_penalizacion_timer)
	auto_penalizacion_timer.one_shot = true
	auto_penalizacion_timer.timeout.connect(_on_penalizacion_automatica)
	aprobado_button.visible = false
	reprobado_button.visible = false
	nervios_button.visible = false
	continue_button.visible = false
	cuadro_votamos.visible = false
	label_votamos.visible = false
	votamos.visible = false	
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
	nervios_button.pressed.connect(_on_nervios_button_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	if animation_player.has_animation("Legis_juego3"):
		animation_player.play("Legis_juego3")
		character_node.visible = true
		color_rect_node.visible = true
		label_node.visible = true
		animation_player.animation_finished.connect(_on_animation_finished)
	else:
		_start_game()

func _start_game():
	aprobado_button.pressed.connect(_on_aprobado_button_pressed)
	reprobado_button.pressed.connect(_on_reprobado_button_pressed)
	game_started = true
	animation_player.play("votacion")
	cuadro_votamos.visible = true
	label_votamos.visible = true
	votamos.visible = true
	character_node.visible = false
	color_rect_node.visible = false
	label_node.visible = false
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_timer_tick)
	countdown_timer.start()
	_update_timer_label()

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
	Jugador.niveles_completados["nivel3"] = true
	var result = Jugador.database.query_with_bindings(sql, [Jugador.puntaje, Jugador.nombre])
	print("✅ Puntaje actualizado en base de datos:", Jugador.puntaje)
	character_node.visible = true
	color_rect_node.visible = true
	aprobado_button.visible = false
	reprobado_button.visible = false
	label_node.visible = true
	print("¡Tiempo terminado!")
	if animation_player.has_animation("Legis_fin3"):
		animation_player.play("Legis_fin3")

func _on_nervios_button_pressed():
	clickButton.play()
	nervios_button.visible = false
	_start_game()

func _on_animation_finished(anim_name: String):
	print("Terminó animación: ", anim_name)
	if anim_name == "Legis_juego3":
		nervios_button.visible = true
	elif anim_name == "Legis_fin3":
		var sql = "UPDATE jugadores SET puntaje = ? WHERE nombre = ?"
		var result = Jugador.database.query_with_bindings(sql, [Jugador.puntaje, Jugador.nombre])
		print("✅ Puntaje actualizado en base de datos:", Jugador.puntaje)
		continue_button.visible = true
		Jugador.niveles_completados["nivel3"] = true
		MusicaMenu.victoria()
	elif anim_name == "votacion":
		aprobado_button.visible = true
		reprobado_button.visible = true
		# Mostrar y arrancar el contador visual
		penalizacion_visual_time = 3
		penalizacion_label.text = str(penalizacion_visual_time)
		penalizacion_label.visible = true
		penalizacion_visual_timer.start()
		# Temporizador de penalización lógica
		auto_penalizacion_timer.start(3.0)
	elif anim_name == "Legis_otra":
		print("Repetimos votación una sola vez")
		animation_player.play("votacion")
		votamos.visible = true
		cuadro_votamos.visible = true
		label_votamos.visible = true
		countdown_timer.start()
		character_node.visible = false
		color_rect_node.visible = false
		label_node.visible = false

func _on_aprobado_button_pressed():
	clickButton.play()
	aplausos.play()
	auto_penalizacion_timer.stop()
	penalizacion_visual_timer.stop()
	penalizacion_label.visible = false
	countdown_timer.stop()
	total_time = 60
	_update_timer_label()
	aprobado_button.visible = false
	reprobado_button.visible = false
	votamos.visible = false
	cuadro_votamos.visible = false
	label_votamos.visible = false
	character_node.visible = true
	color_rect_node.visible = true
	label_node.visible = true
	if not ya_repetido:
		animation_player.play("Legis_otra")
		ya_repetido = true  # Marcamos que ya se repitió
	else:
		animation_player.play("Legis_fin3")
	print("Respuesta correcta.")

func _on_reprobado_button_pressed():
	clickButton.play()
	aplausos.play()
	auto_penalizacion_timer.stop()
	penalizacion_visual_timer.stop()
	penalizacion_label.visible = false
	countdown_timer.stop()
	total_time = 60
	_update_timer_label()
	aprobado_button.visible = false
	reprobado_button.visible = false
	votamos.visible = false
	cuadro_votamos.visible = false
	label_votamos.visible = false
	character_node.visible = true
	color_rect_node.visible = true
	label_node.visible = true
	if not ya_repetido:
		animation_player.play("Legis_otra")
		ya_repetido = true  # Marcamos que ya se repitió
	else:
		animation_player.play("Legis_fin3")
	print("Respuesta correcta.")

func _on_penalizacion_automatica():
	print("⏰ No respondió a tiempo. Penalización aplicada.")
	Jugador.puntaje -= 50
	_update_timer_label()
	aprobado_button.visible = false
	reprobado_button.visible = false
	votamos.visible = false
	cuadro_votamos.visible = false
	label_votamos.visible = false
	character_node.visible = true
	color_rect_node.visible = true
	label_node.visible = true
	if not ya_repetido:
		animation_player.play("Legis_otra")
		ya_repetido = true
	else:
		animation_player.play("Legis_fin3")

func _on_penalizacion_visual_tick():
	penalizacion_visual_time -= 1
	if penalizacion_visual_time <= 0:
		penalizacion_visual_timer.stop()
		penalizacion_label.visible = false
	else:
		penalizacion_label.text = str(penalizacion_visual_time)

func _on_continue_pressed():
	clickButton.play()
	TRANSICION.change_scene_loc("res://Escenas/mapa.tscn")
