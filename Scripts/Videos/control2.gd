extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	MusicaMenu.juego1()
	video_player.play()
	video_player.connect("finished", Callable(self, "_on_video_finished"))

func _on_video_finished():
	# Cargar la escena del juego
	TRANSICION.change_scene_loc("res://Escenas/juego.tscn")
