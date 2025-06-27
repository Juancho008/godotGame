extends CharacterBody2D

signal person_clicked(person)

@export var is_correct: bool = false
@onready var shader := $Sprite2D.material as ShaderMaterial
@onready var dialogo = $dialogo
@onready var dialogo_label = $dialogo/dialogo_label
@onready var animation_player = $AnimationPlayer
var is_talking := false

func _ready():
	$Area2D.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	$Area2D.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	$Area2D.connect("input_event", Callable(self, "_on_input_event"))
	dialogo.visible = false
	dialogo.modulate.a = 0.0
	dialogo.scale = Vector2(0.6, 0.6)
	$HaloSprite.visible = false

func _on_mouse_entered():
	$Sprite2D.modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited():
	$Sprite2D.modulate = Color(1, 1, 1)

func set_phrase(text: String, short := false, force := false) -> void:
	if is_talking and not force:
		return
	is_talking = true
	dialogo_label.text = text
	dialogo.visible = true
	dialogo.modulate.a = 1.0
	dialogo.scale = Vector2(1, 1)
	# Tiempo en pantalla: 1s si es corto, 2.6s si no
	var delay = 1.0 if short else 2.6
	await get_tree().create_timer(delay).timeout
	# Ocultar
	dialogo.modulate.a = 0.0
	dialogo.visible = false
	is_talking = false

func hide_dialog():
	if dialogo.visible:
		dialogo.modulate.a = 0.0
		dialogo.visible = false
		is_talking = false

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("person_clicked", self)

func set_selected(selected: bool):
	$HaloSprite.visible = selected

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "ocultar_dialogo":
		dialogo.visible = false
