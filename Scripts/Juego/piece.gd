class_name Piece
extends Control

signal placed_correctly

@export var correct_position: Vector2
var is_dragging := false
var placed := false  # ← Nuevo: rastrea si ya está bien colocada

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event):
	if placed:
		return  # Ya está colocada correctamente, no se arrastra más

	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			is_dragging = true
		else:
			is_dragging = false
			check_if_in_place()
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and is_dragging:
		global_position += event.relative

func check_if_in_place():
	if global_position.distance_to(correct_position) < 20:
		global_position = correct_position
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		placed = true  # ← Marcamos como colocada
		emit_signal("placed_correctly")

func is_correctly_placed() -> bool:
	return placed  # ← Más confiable que comparar distancia cada frame

func set_texture(texture: Texture2D) -> void:
	$TextureRect.texture = texture
