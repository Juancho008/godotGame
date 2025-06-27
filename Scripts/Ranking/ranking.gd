extends Control

@onready var vbox = $VBoxContainer
@onready var template_row = $VBoxContainer/TemplateRow
@onready var volver_button = $BotonVolver
@onready var clickButton = $clickButton

var database : SQLite

func _ready():
	MusicaMenu.ranking()
	print(">> Escena de ranking cargada")
	volver_button.pressed.connect(_on_boton_volver_pressed)
	abrir_base_de_datos()
	mostrar_ranking()

func abrir_base_de_datos():
	print(">> Intentando abrir base de datos desde user://")
	var db_path_user = "user://caminoLeyBD.db"
	var db_path_res = "res://addons/caminoLeyBD.db"

	if not FileAccess.file_exists(db_path_user):
		print("⚠️ No existe user://caminoLeyBD.db, copiando desde res://")
		var file_src = FileAccess.open(db_path_res, FileAccess.READ)
		if file_src == null:
			print("❌ No se pudo abrir el archivo de base de datos en res://")
			return
		
		var file_dest = FileAccess.open(db_path_user, FileAccess.WRITE)
		if file_dest == null:
			print("❌ No se pudo crear el archivo de base de datos en user://")
			return
		
		var data = file_src.get_buffer(file_src.get_length())
		file_dest.store_buffer(data)
		file_src.close()
		file_dest.close()
		print("✅ Base de datos copiada a user://")

	database = SQLite.new()
	database.path = db_path_user
	if database.open_db():
		print("✅ Base de datos abierta correctamente")
	else:
		print("❌ Error al abrir la base de datos")

func mostrar_ranking():
	print(">> Ejecutando mostrar_ranking()")

	if database == null:
		print("❌ database es null. No se puede consultar.")
		return

	# Limpiar VBoxContainer excepto template_row
	for child in vbox.get_children():
		if child != template_row:
			vbox.remove_child(child)
			child.queue_free()

	var sql = "SELECT nombre, puntaje FROM jugadores WHERE puntaje IS NOT NULL ORDER BY puntaje DESC LIMIT 6"
	print(">> Ejecutando SQL:", sql)

	if not database.query(sql):
		print("❌ Error al ejecutar la consulta SQL")
		return

	print("✅ Consulta ejecutada correctamente. Procesando resultados...")

	var count = 0
	for row in database.query_result:
		var nombre = str(row["nombre"])
		var puntaje = int(row["puntaje"])

		var row_node = template_row.duplicate()
		row_node.visible = true

		# Asegurate de que los nombres de nodos coincidan con los de la escena
		var nombre_label = row_node.get_node("NombreLabel")
		var separador_label = row_node.get_node("SeparadorLabel")
		var puntaje_label = row_node.get_node("PuntajeLabel")

		if nombre_label and puntaje_label and separador_label:
			nombre_label.text = nombre
			separador_label.text = " - "
			puntaje_label.text = "%d puntos" % puntaje
			vbox.add_child(row_node)
			print("✅ Agregado al ranking:", nombre, puntaje)
			count += 1
		else:
			print("❌ No se encontró alguno de los nodos en TemplateRow duplicado")

	if count == 0:
		print("⚠️ No se encontraron resultados.")

func _on_boton_volver_pressed():
	clickButton.play()
	print(">> Botón VOLVER presionado")
	TRANSICION.change_scene_loc("res://Escenas/menu.tscn")
