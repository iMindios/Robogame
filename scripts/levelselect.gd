extends Control

@onready var grid := $GridContainer

func _ready() -> void:
	print("[levelselect] Ready, Buttons under:", grid.get_children())
	for btn in grid.get_children():
		if btn is Button:
			# Godot 4: bind() liefert ein Callable mit gebundenen Argumenten
			# und wird direkt an connect() übergeben :contentReference[oaicite:0]{index=0}
			btn.pressed.connect(_on_level_pressed.bind(btn.name))

func _on_level_pressed(level_name: String) -> void:
	print("[levelselect] Button pressed:", level_name)
	var num := level_name.get_slice("_", 1)
	# Zero‑Padding für Einzelstellen
	if num.length() == 1:
		num = "0" + num
	var scene_path = "res://scenes/levelselect/level_%s.tscn" % num
	Transition.transition_to(scene_path)
	
