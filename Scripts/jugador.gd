# Jugador.gd
extends Node

var nombre = ""
var puntaje = 0
var database : SQLite = null

# En jugador.gd (autoload)
var niveles_completados = {
	"nivel1": false,
	"nivel2": false,
	"nivel3": false,
	"nivel4": false
}
