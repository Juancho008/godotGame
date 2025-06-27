extends Control

@onready var opcion_pantalla = $SettingsTabs/Video/MarginContainer/VideoSettings/BtnDisplay
@onready var slider_volumen = $SettingsTabs/Audio/MarginContainer/MaxAudioContainer/MaxAudio
@onready var clickButton = $clickButton

func _ready():
	MusicaMenu.menu()
	opcion_pantalla.clear()
	opcion_pantalla.add_item("Ventana")
	opcion_pantalla.add_item("Pantalla completa")
	cargar_config()
	var modo = DisplayServer.window_get_mode()
	if modo == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		opcion_pantalla.select(1)
	else:
		opcion_pantalla.select(0)
	
func _set_volumen(valor: float):
	# Convierte de 0–100 a decibelios (-80 dB a 0 dB)
	var db = lerp(-80.0, 0.0, valor / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
func _on_btn_display_item_selected(index: int) -> void:
	print("Cambiar modo de pantalla a:", index)
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
func guardar_config():
	var config = ConfigFile.new()
	config.set_value("audio", "volumen", slider_volumen.value)
	config.save("user://config.cfg")
func cargar_config():
	var config = ConfigFile.new()
	if config.load("user://config.cfg") == OK:
		var v = config.get_value("audio", "volumen", 100)
		slider_volumen.value = v
		_set_volumen(v)
func _on_max_audio_value_changed(value: float) -> void:
	_set_volumen(value)
func _on_button_pressed() -> void:
	clickButton.play()
	TRANSICION.change_scene_loc("res://Escenas/menu.tscn")
