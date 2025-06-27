extends Popup


#Video Settings
onready var display_options = get_node("SettingsTabs/Video/MarginContainer/VideoSettings/BtnDisplay")
onready var vsync_btn = get_node("SettingsTabs/Video/MarginContainer/VideoSettings/BtnVsync")
onready var display_fps_btn = get_node("SettingsTabs/Video/MarginContainer/VideoSettings/BtnFps")
onready var max_fps_slider = $SettingsTabs/Video/MarginContainer/VideoSettings/MaxFpsContainer/SliderMaxFps
onready var max_fps_val = get_node("SettingsTabs/Video/MarginContainer/VideoSettings/MaxFpsContainer/LabelCurrentFps")
onready var brightness = get_node("SettingsTabs/Video/MarginContainer/VideoSettings/SliderBrightness")

#Audio Settings
onready var master_slider = get_node("SettingsTabs/Audio/MarginContainer/GridContainer/SliderMasterVol")
onready var music_slider = get_node("SettingsTabs/Audio/MarginContainer/GridContainer/SliderMusicVol")
onready var sfx_slider = get_node("SettingsTabs/Audio/MarginContainer/GridContainer/SliderSFXVol")

#Gameplay Settings
onready var fov_amount = get_node("SettingsTabs/Gameplay/MarginContainer/GridContainer/HBoxContainer/FovAmount")
onready var fov_slider = get_node("SettingsTabs/Gameplay/MarginContainer/GridContainer/HBoxContainer/SliderFov")
onready var mouse_sens_amount = get_node("SettingsTabs/Gameplay/MarginContainer/GridContainer/HBoxContainer2/FovAmount")
onready var mouse_slider = get_node("SettingsTabs/Gameplay/MarginContainer/GridContainer/HBoxContainer2/SliderMouseSens")

func _ready() -> void:
	display_options.select(1 if Save.game_data.full_screen_on else 0)
	GlobalSettings.change_displayMode(Save.game_data.full_screen_on)
	vsync_btn.pressed = Save.game_data.vsync_on
	display_fps_btn.pressed = Save.game_data.display_fps
	max_fps_slider.value = Save.game_data.max_fps
	brightness.value = Save.game_data.brightness
	master_slider.value = Save.game_data.master_vol
	music_slider.value = Save.game_data.music_vol
	sfx_slider.value = Save.game_data.sfx_vol
	fov_slider.value = Save.game_data.fov
	mouse_slider = Save.game_data.mouse_sens
	
func _on_BtnDisplay_item_selected(index: int) -> void:
	GlobalSettings.change_displayMode(index)

func _on_BtnVsync_toggled(button_pressed: bool) -> void:
	GlobalSettings.change_vsync(button_pressed)

func _on_BtnFps_toggled(button_pressed: bool) -> void:
	GlobalSettings.toggle_fps_display(button_pressed)

func _on_SliderMaxFps_value_changed(value: float) -> void:
	GlobalSettings.set_max_fps(value)
	max_fps_val.text = value as String if value < max_fps_slider.max_value else "max"

func _on_SliderBrightness_value_changed(value: float) -> void:
	GlobalSettings.update_brightness(value)

func _on_SliderMasterVol_value_changed(value: float) -> void:
	GlobalSettings.update_master_vol(0, value)

func _on_SliderMusicVol_value_changed(value: float) -> void:
	GlobalSettings.update_master_vol(1, value)

func _on_SliderSFXVol_value_changed(value: float) -> void:
	GlobalSettings.update_master_vol(2, value)

func _on_SliderMouseSens_value_changed(value: float) -> void:
	GlobalSettings.update_mouse_sens(value)
	
	mouse_sens_amount.text = value as String

func _on_SliderFov_value_changed(value: float) -> void:
	GlobalSettings.update_fov(value)


func _on_SettingsMenu_popup_hide() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
