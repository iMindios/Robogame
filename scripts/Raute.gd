extends Area2D

signal form_completed(caller)

# Typ der Form für Zählung
@export var shape_type: String = "raute"
# Index der Startposition (vom Level gesetzt)
@export var start_index: int = 0
# Name des Zielbereichs
@export var target_zone_name: String = "zielbereich_raute"

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var locked: bool = false

func _process(delta: float) -> void:
	if dragging and not locked:
		global_position = get_global_mouse_position() + drag_offset

func _input_event(viewport, event, shape_idx) -> void:
	if locked:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - event.position
		else:
			dragging = false
			for area in get_overlapping_areas():
				if area.name == target_zone_name:
					var tween = create_tween()
					tween.tween_property(self, "global_position", area.global_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					tween.tween_property(self, "scale", self.scale * 2, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					tween.tween_callback(Callable(self, "lock"))
					break

func lock() -> void:
	locked = true
	set_process_input(false)
	# Signal an Level senden, damit Zählung und Spawn erfolgen
	emit_signal("form_completed", self)
