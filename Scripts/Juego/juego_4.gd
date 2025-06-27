extends Node2D

@export var image_path: String = "res://Imagenes/sello_chico.png"
@export var piece_scene: PackedScene
@export var piece_size: Vector2i = Vector2i(200, 200)

@onready var timer_label = $TimerLabel
@onready var countdown_timer = $CountdownTimer
@onready var animation_player = $AnimationPlayer
@onready var character_node = $AnimationPlayer/CharacterBody2D
@onready var color_rect_node = $AnimationPlayer/ColorRectLegis
@onready var label_node = $AnimationPlayer/LabelLegis
@onready var seguro_button = $seguroButton
@onready var packedScene = $PackedScene
@onready var ranking = $ranking
@onready var clickButton = $clickButton

var total_time := 60
var game_started := false
var piezas_totales := 0
var piezas_colocadas := 0

func _ready():
	MusicaMenu.juego4()
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
	piece_scene = load("res://Escenas/Piece.tscn")
	randomize()
	packedScene.visible = false
	seguro_button.visible = false
	ranking.visible = false
	ranking.pressed.connect(_on_ranking_pressed)
	seguro_button.pressed.connect(Callable(self, "_on_seguro_button_pressed"))
	
	if animation_player.has_animation("Legis_juego4"):
		animation_player.play("Legis_juego4")
		character_node.visible = true
		color_rect_node.visible = true
		label_node.visible = true
		ranking.visible = false
		animation_player.animation_finished.connect(Callable(self, "_on_animation_finished"))
	else:
		_start_game()

func _start_game():
	packedScene.visible = true
	game_started = true
	piezas_colocadas = 0
	
	character_node.visible = false
	color_rect_node.visible = false
	label_node.visible = false
	
	var image: Image = load(image_path).get_image()
	var cols: int = int(image.get_width() / piece_size.x)
	var rows: int = int(image.get_height() / piece_size.y)
	piezas_totales = cols * rows

	var total_width = cols * piece_size.x
	var total_height = rows * piece_size.y
	var viewport_size = get_viewport_rect().size

	var offset_x = (viewport_size.x - total_width) / 2
	var offset_y = 200
	var offset = Vector2(offset_x, offset_y)

	for y in range(rows):
		for x in range(cols):
			var pos = Vector2(x * piece_size.x, y * piece_size.y) + offset
			var guia := ColorRect.new()
			guia.color = Color(0.8, 0.8, 0.8, 0.3)
			guia.size = piece_size
			guia.position = pos
			add_child(guia)
			var sub_image: Image = image.get_region(Rect2i(Vector2(x * piece_size.x, y * piece_size.y), piece_size))
			var texture: ImageTexture = ImageTexture.create_from_image(sub_image)
			var piece = piece_scene.instantiate()
			piece.set_texture(texture)
			piece.correct_position = pos
			piece.connect("placed_correctly", Callable(self, "_on_piece_placed"))
			var random_pos: Vector2
			var forbidden_rect = Rect2(offset - Vector2(20, 20), Vector2(total_width + 40, total_height + 40))
			var padding = 20
			var tries = 0
			while true:
				random_pos = Vector2(
					randf_range(padding, viewport_size.x - piece_size.x - padding),
					randf_range(padding, viewport_size.y - piece_size.y - padding)
				)
				if not forbidden_rect.has_point(random_pos):
					break
				tries += 1
				if tries > 100:
					break
			piece.position = random_pos
			add_child(piece)

	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(Callable(self, "_on_timer_tick"))
	countdown_timer.start()
	_update_timer_label()

func _on_animation_finished(anim_name: String):
	print("Terminó animación: ", anim_name)
	if anim_name == "Legis_juego4":
		print("Mostrar botón para iniciar juego")
		seguro_button.visible = true
	elif anim_name == "Legis_fin4":
		ranking.visible = true
		print("✅ Puntaje actualizado en base de datos:", Jugador.puntaje)
		MusicaMenu.victoria()

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
	var result = Jugador.database.query_with_bindings(sql, [Jugador.puntaje, Jugador.nombre])
	print("✅ Puntaje actualizado en base de datos:", Jugador.puntaje)
	Jugador.niveles_completados["nivel4"] = true
	print("¡Tiempo terminado!")
	if animation_player.has_animation("Legis_fin4"):
		character_node.visible = true
		color_rect_node.visible = true
		label_node.visible = true
		animation_player.play("Legis_fin4")

func _on_seguro_button_pressed():
	clickButton.play()
	print("Botón de seguro presionado. Iniciando juego...")
	seguro_button.visible = false
	character_node.visible = false
	color_rect_node.visible = false
	label_node.visible = false
	_start_game()

func _on_ranking_pressed():
	clickButton.play()
	TRANSICION.change_scene_loc("res://Escenas/fin_ultimo_juego.tscn")

func _on_piece_placed():
	piezas_colocadas += 1
	if piezas_colocadas == piezas_totales:
		_on_puzzle_completed()

func _on_puzzle_completed():
	Jugador.niveles_completados["nivel4"] = true
	if not game_started:
		return
	game_started = false
	countdown_timer.stop()
	var sql = "UPDATE jugadores SET puntaje = ? WHERE nombre = ?"
	var result = Jugador.database.query_with_bindings(sql, [Jugador.puntaje, Jugador.nombre])
	print("🎉 Puzzle completo, lanzando animación final.")
	if animation_player.has_animation("Legis_fin4"):
		packedScene.visible = false
		seguro_button.visible = false
		animation_player.play("Legis_fin4")
		character_node.visible = true
		color_rect_node.visible = true
		label_node.visible = true
