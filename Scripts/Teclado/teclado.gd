extends Control

@onready var input_nombre = $InputNombre
@onready var btn_aceptar = $BtnAceptar
@onready var buttonShort = $buttonShort

var db = null
var database : SQLite

func _ready():
	# Conectar los botones con la función que agrega caracteres
	$GridContainer/Button1.connect("pressed", Callable(self, "_on_button_pressed").bind("1"))
	$GridContainer/Button2.connect("pressed", Callable(self, "_on_button_pressed").bind("2"))
	$GridContainer/Button3.connect("pressed", Callable(self, "_on_button_pressed").bind("3"))
	$GridContainer/Button4.connect("pressed", Callable(self, "_on_button_pressed").bind("4"))
	$GridContainer/Button5.connect("pressed", Callable(self, "_on_button_pressed").bind("5"))
	$GridContainer/Button6.connect("pressed", Callable(self, "_on_button_pressed").bind("6"))
	$GridContainer/Button7.connect("pressed", Callable(self, "_on_button_pressed").bind("7"))
	$GridContainer/Button8.connect("pressed", Callable(self, "_on_button_pressed").bind("8"))
	$GridContainer/Button9.connect("pressed", Callable(self, "_on_button_pressed").bind("9"))
	$GridContainer/Button0.connect("pressed", Callable(self, "_on_button_pressed").bind("0"))
	$GridContainer/Buttonq.connect("pressed", Callable(self, "_on_button_pressed").bind("q"))
	$GridContainer/Buttonw.connect("pressed", Callable(self, "_on_button_pressed").bind("w"))
	$GridContainer/Buttone.connect("pressed", Callable(self, "_on_button_pressed").bind("e"))
	$GridContainer/Buttonr.connect("pressed", Callable(self, "_on_button_pressed").bind("r"))
	$GridContainer/Buttont.connect("pressed", Callable(self, "_on_button_pressed").bind("t"))
	$GridContainer/Buttony.connect("pressed", Callable(self, "_on_button_pressed").bind("y"))
	$GridContainer/Buttonu.connect("pressed", Callable(self, "_on_button_pressed").bind("u"))
	$GridContainer/Buttoni.connect("pressed", Callable(self, "_on_button_pressed").bind("i"))
	$GridContainer/Buttono.connect("pressed", Callable(self, "_on_button_pressed").bind("o"))
	$GridContainer/Buttonp.connect("pressed", Callable(self, "_on_button_pressed").bind("p"))
	$GridContainer/Buttona.connect("pressed", Callable(self, "_on_button_pressed").bind("a"))
	$GridContainer/Buttons.connect("pressed", Callable(self, "_on_button_pressed").bind("s"))
	$GridContainer/Buttond.connect("pressed", Callable(self, "_on_button_pressed").bind("d"))
	$GridContainer/Buttonf.connect("pressed", Callable(self, "_on_button_pressed").bind("f"))
	$GridContainer/Buttong.connect("pressed", Callable(self, "_on_button_pressed").bind("g"))
	$GridContainer/Buttonh.connect("pressed", Callable(self, "_on_button_pressed").bind("h"))
	$GridContainer/Buttonj.connect("pressed", Callable(self, "_on_button_pressed").bind("j"))
	$GridContainer/Buttonk.connect("pressed", Callable(self, "_on_button_pressed").bind("k"))
	$GridContainer/Buttonl.connect("pressed", Callable(self, "_on_button_pressed").bind("l"))
	$GridContainer/Buttonñ.connect("pressed", Callable(self, "_on_button_pressed").bind("ñ"))
	$GridContainer/Buttonz.connect("pressed", Callable(self, "_on_button_pressed").bind("z"))
	$GridContainer/Buttonx.connect("pressed", Callable(self, "_on_button_pressed").bind("x"))
	$GridContainer/Buttonc.connect("pressed", Callable(self, "_on_button_pressed").bind("c"))
	$GridContainer/Buttonv.connect("pressed", Callable(self, "_on_button_pressed").bind("v"))
	$GridContainer/Buttonb.connect("pressed", Callable(self, "_on_button_pressed").bind("b"))
	$GridContainer/Buttonn.connect("pressed", Callable(self, "_on_button_pressed").bind("n"))
	$GridContainer/Buttonm.connect("pressed", Callable(self, "_on_button_pressed").bind("m"))
	$GridContainer/Button_punto.connect("pressed", Callable(self, "_on_button_pressed").bind("."))
	
	# Botón borrar conecta con su propia función
	$GridContainer/Button_borrar.connect("pressed", Callable(self, "_on_button_borrar_pressed"))
	
	# Copiar DB a user:// si no existe para poder escribir
	var db_path_user = "user://caminoLeyBD.db"
	var db_path_res = "res://addons/caminoLeyBD.db"
	
	if not FileAccess.file_exists(db_path_user):
		var file_src = FileAccess.open(db_path_res, FileAccess.READ)
		if file_src == null:
			print("No se pudo abrir el archivo de base de datos en res://")
			return
		
		var file_dest = FileAccess.open(db_path_user, FileAccess.WRITE)
		if file_dest == null:
			print("No se pudo crear el archivo de base de datos en user://")
			return
		
		var data = file_src.get_buffer(file_src.get_length())
		file_dest.store_buffer(data)
		file_src.close()
		file_dest.close()

	# Abrir base de datos desde user://
	Jugador.database = SQLite.new()
	Jugador.database.path = "user://caminoLeyBD.db"
	Jugador.database.open_db()
	database = SQLite.new()
	database.path = db_path_user
	if not database.open_db():
		print("No se pudo abrir la base de datos")
		return
	
	# Crear tabla si no existe
	database.query("CREATE TABLE IF NOT EXISTS jugadores (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, puntaje INTEGER)")
	
	# Conectar botón aceptar (por si no está conectado en el editor)
	btn_aceptar.connect("pressed", Callable(self, "_on_btn_aceptar_pressed"))
	

func add_char(c: String) -> void:
	input_nombre.text += c

func delete_char() -> void:
	if input_nombre.text.length() > 0:
		input_nombre.text = input_nombre.text.substr(0, input_nombre.text.length() - 1)

@warning_ignore("shadowed_global_identifier")
func _on_button_pressed(char: String) -> void:
	buttonShort.play()
	add_char(char)
	
func _on_button_borrar_pressed() -> void:
	buttonShort.play()
	delete_char()

func _on_btn_aceptar_pressed() -> void:
	buttonShort.play()
	var nombre = input_nombre.text.strip_edges()
	if nombre.is_empty():
		print("Nombre vacío. Ingresá un nombre válido.")
		return
	
	var sql = "INSERT INTO jugadores (nombre, puntaje) VALUES (?, NULL)"
	var result = database.query_with_bindings(sql,[nombre])
	Jugador.nombre = nombre
	TRANSICION.change_scene_loc("res://Escenas/mapa.tscn")
	if result == null:
		print("Error al guardar jugador en la base de datos")
	else:
		print("Jugador guardado:", nombre)
	
	# Acá podrías ir a otra escena si querés:
