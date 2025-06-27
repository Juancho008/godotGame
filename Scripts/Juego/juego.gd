extends Node2D

var db = null
var database : SQLite

@onready var audio_npc_h = $dolor_hombre
@onready var victoria = $victoria
@onready var clickButton = $clickButton
@onready var npc_scenes = [
	preload("res://Personajes/npc-1.tscn"),
	preload("res://Personajes/npc-2.tscn"),
	preload("res://Personajes/npc-3.tscn"),
	preload("res://Personajes/npc-4.tscn"),
	preload("res://Personajes/npc-5.tscn"),
	
]
@onready var timer_label = $TimerLabel
@onready var countdown_timer = $CountdownTimer
@onready var animation_player = $AnimationPlayer
@onready var continue_button = $ContinueButton
@onready var ayudar_button = $AyudarButton
@onready var character_node = $AnimationPlayer/CharacterBody2D
@onready var color_rect_node = $AnimationPlayer/ColorRectLegis
@onready var label_node = $AnimationPlayer/LabelLegis
@onready var color_rect_pregunta = $AnimationPlayer/ColorRectPregunta
@onready var label_pregunta = $AnimationPlayer/LabelPregunta

var correct_phrase = "16 Años!"
var wrong_phrases = [
	"4 Años!", "5 Años!", "6 Años!", "7 Años!", "8 Años!",
	"9 Años!", "10 Años!", "11 Años!", "12 Años!", "13 Años!",
	"14 Años!", "15 Años!", "19 Años!", "17 Años!"
]
var wrong_feedback_phrases = ["¡Uh!", "¡Nop!", "¡Casi!"]
var total_time := 60
var characters = []
var selected_npc : Node = null
var game_started := false
var pause_random_talk := false

func _ready():
	Jugador.puntaje = 100
	print("Puntaje inicial:", Jugador.puntaje)
	continue_button.visible = false
	ayudar_button.visible = false
	character_node.visible = false
	color_rect_node.visible = false
	color_rect_pregunta.visible = false
	label_node.visible = false
	label_pregunta.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	ayudar_button.pressed.connect(_on_ayudar_pressed)
	animation_player.animation_finished.connect(_on_cutscene_finished)
	if animation_player.has_animation("Legis_inicio"):
		animation_player.play("Legis_inicio")
		character_node.visible = true
		color_rect_node.visible = true
		label_node.visible = true
	else:
		_start_game()

func _start_game():
	label_pregunta.visible = true
	color_rect_pregunta.visible = true
	animation_player.play("pregunta")
	game_started = true
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_timer_tick)
	countdown_timer.start()
	_update_timer_label()
	randomize()
	var positions = [
		Vector2(100, 700),
		Vector2(530, 700),
		Vector2(860, 700),
		Vector2(1160, 700)
	]
	# Lista completa de NPCs disponibles
	var todos_los_npcs = [
		"res://Personajes/npc-1.tscn",
		"res://Personajes/npc-2.tscn",
		"res://Personajes/npc-3.tscn",
		"res://Personajes/npc-4.tscn",
		"res://Personajes/npc-5.tscn",
		"res://Personajes/npc-6.tscn",
		"res://Personajes/npc-7.tscn",
		"res://Personajes/npc-8.tscn",
		"res://Personajes/npc-9.tscn",
		"res://Personajes/npc-10.tscn",
	]
	# NPCs que pueden ser correctos (excluimos npc-2 y npc-3)
	var npcs_validos_para_correcto = [
		"res://Personajes/npc-1.tscn",
		"res://Personajes/npc-4.tscn",
		"res://Personajes/npc-5.tscn",
		"res://Personajes/npc-6.tscn",
		"res://Personajes/npc-7.tscn",
		"res://Personajes/npc-8.tscn",
		"res://Personajes/npc-9.tscn",
		"res://Personajes/npc-10.tscn",
	]
	# Elegimos un NPC al azar que será el correcto
	var ruta_correcto = npcs_validos_para_correcto[randi() % npcs_validos_para_correcto.size()]
	# Creamos una copia de todos los NPCs y quitamos el correcto
	var pool_npcs = todos_los_npcs.duplicate()
	pool_npcs.erase(ruta_correcto)
	# Elegimos 3 NPCs más para completar los 4
	pool_npcs.shuffle()
	var seleccionados = [ruta_correcto] + pool_npcs.slice(0, 3)
	seleccionados.shuffle()
	# Instanciamos y ubicamos los NPCs
	for i in range(seleccionados.size()):
		var scene = load(seleccionados[i])
		var character = scene.instantiate()
		character.position = positions[i]
		character.is_correct = (seleccionados[i] == ruta_correcto)
		character.connect("person_clicked", Callable(self, "_on_person_clicked"))
		add_child(character)
		characters.append(character)
	start_random_talking_loop()

func _hide_all_dialogs(): 
	for c in characters:
		c.hide_dialog()

func _on_ayudar_pressed():
	ayudar_button.visible = false
	character_node.visible = false
	color_rect_node.visible = false
	label_node.visible = false
	clickButton.play()
	animation_player.play("Legis_oculto")
	_start_game()

func _on_person_clicked(person):
	if selected_npc and selected_npc != person:
		selected_npc.set_selected(false)
	person.set_selected(true)
	selected_npc = person
	pause_random_talk = true
	if person.is_correct:
		print("¡Correcto!")
		label_pregunta.visible = false
		color_rect_pregunta.visible = false
		# Detener el tiempo y limpiar
		countdown_timer.stop()
		selected_npc = null
		for npc in characters:
			npc.queue_free()
		characters.clear()
		# Mostrar elementos visuales de la cutscene final
		character_node.visible = true
		color_rect_node.visible = true
		label_node.visible = true
		# Reproducir cutscene de final correcto
		if animation_player.has_animation("Legis_siguiente"):
			animation_player.play("Legis_siguiente")
			
	else:
		print("Incorrecto")
		var feedback = wrong_feedback_phrases[randi() % wrong_feedback_phrases.size()]
		audio_npc_h.play()
		await person.set_phrase(feedback, true, true)
		Jugador.puntaje = max(Jugador.puntaje - 10, 0)
		await _esperar_y_apagar_halo(person)

func _esperar_y_apagar_halo(person):
	await get_tree().create_timer(0.2).timeout  # Espera suave (puede ajustar)
	if is_instance_valid(person) and person == selected_npc:
		person.set_selected(false)
		selected_npc = null
	pause_random_talk = false
	_random_talk()

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

func start_random_talking_loop():
	_random_talk()

func _random_talk():
	if pause_random_talk or characters.size() == 0:
		return
	for c in characters:
		if c.is_talking:
			await get_tree().create_timer(0.5).timeout
			_random_talk()
			return
	var npc = characters[randi() % characters.size()]
	for c in characters:
		if c != npc:
			c.hide_dialog()
	if npc.is_correct:
		await npc.set_phrase(correct_phrase, false)
	else:
		var frase_incorrecta = wrong_phrases[randi() % wrong_phrases.size()]
		await npc.set_phrase(frase_incorrecta, false)
	await get_tree().create_timer(2.5).timeout
	_random_talk()

func _on_timer_finished():
	label_pregunta.visible = false
	color_rect_pregunta.visible = false
	character_node.visible = true
	color_rect_node.visible = true
	label_node.visible = true
	print("¡Tiempo terminado!")
	for npc in characters:
		npc.queue_free()
	characters.clear()
	if animation_player.has_animation("Legis_siguiente"):
		animation_player.play("Legis_siguiente")
	Jugador.niveles_completados["nivel1"] = true
	
func _on_cutscene_finished(anim_name):
	if anim_name == "Legis_siguiente":
		continue_button.visible = true
		var sql = "UPDATE jugadores SET puntaje = ? WHERE nombre = ?"
		var result = Jugador.database.query_with_bindings(sql, [Jugador.puntaje, Jugador.nombre])
		print("✅ Puntaje guardado para", Jugador.nombre, ":", Jugador.puntaje)
		Jugador.niveles_completados["nivel1"] = true
		MusicaMenu.victoria()
	elif anim_name == "Legis_inicio" and not game_started:
		ayudar_button.visible = true

func _on_continue_pressed():
	clickButton.play()
	TRANSICION.change_scene_loc("res://Escenas/mapa.tscn")
