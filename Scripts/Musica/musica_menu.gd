extends Node2D

@onready var musica_menu = $MusicaMenu
@onready var musica_juego1 = $MusicaJuego1
@onready var musica_juego2 = $MusicaJuego2
@onready var musica_juego3 = $MusicaJuego3
@onready var musica_juego4 = $MusicaJuego4
@onready var musica_ranking = $Ranking
@onready var musica_victoria = $Victoria

var musica_actual : AudioStreamPlayer2D = null

func reproducir_musica(nueva_musica: AudioStreamPlayer2D):
	if not nueva_musica:
		push_warning("Intentaste reproducir una música que no existe (nueva_musica es null)")
		return

	if musica_actual and musica_actual != nueva_musica:
		musica_actual.stop()

	if not nueva_musica.playing:
		nueva_musica.play()

	musica_actual = nueva_musica

func menu():
	reproducir_musica(musica_menu)

func juego1():
	reproducir_musica(musica_juego1)

func juego2():
	reproducir_musica(musica_juego2)

func juego3():
	reproducir_musica(musica_juego3)

func juego4():
	reproducir_musica(musica_juego4)

func ranking():
	reproducir_musica(musica_ranking)

func victoria():
	reproducir_musica(musica_victoria)

func detener_musica():
	if musica_actual:
		musica_actual.stop()
		musica_actual = null
