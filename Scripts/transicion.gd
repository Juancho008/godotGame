extends CanvasLayer

var anima_play
var blocker : Control

func _ready() -> void:
	layer = -1
	anima_play = $AnimationPlayer
	blocker = $Blocker
	blocker.visible = false
	blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE


func change_scene_loc(path: String) -> void:
	layer = 1
	blocker.visible = true
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	
	anima_play.play("fade")
	await anima_play.animation_finished
	
	var err = get_tree().change_scene_to_file(path)
	if err != OK:
		print("Error al cambiar escena: ", err)
	
	blocker.visible = false
	blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer = -1
