extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	video_player.play()
	video_player.connect("finished", Callable(self, "_on_video_finished"))
	MusicaMenu.ranking()
func _on_video_finished():
	# Cargar la escena del juego
	TRANSICION.change_scene_loc("res://Escenas/ranking.tscn")
