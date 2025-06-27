extends Node
var database : SQLite
func _ready():
	database = SQLite.new()
	database.path = "res://addons/caminoLeyBD.db"
	database.open_db()  # Asegúrate de la ruta correcta y que el archivo exista
