extends Node2D

# Globaler Pool: 3x Dreieck, 3x Quadrat, 3x Kreis
var shape_pool: Array[String] = []
# Optional: Zähler für gelockte Formen insgesamt
var total_locked: int = 0

# Pfade zu den Form-Szenen
var base_paths: Dictionary = {
		"rechteck": "res://assets/graphics/shapes/weis_rechteck.tscn",
		"stern":    "res://assets/graphics/shapes/weis_stern.tscn",
		"quadrat":  "res://assets/graphics/shapes/weis_quadrat.tscn"
}

# Overlay und Pause-Menü
@onready var overlay: Control = $Overlay
var PauseMenuScene: PackedScene = preload("res://scenes/common/pausemenu.tscn")
var pause_menu: Popup

# Ursprüngliche Positionen der Spawn-Punkte
var original_positions: Array[Vector2] = []

func _ready() -> void:
	randomize()
	# Pool initialisieren (3x jeder Typ)
	for t in ["quadrat", "stern", "rechteck"]:
		for i in range(3):
			shape_pool.append(t)

	# Pause-Menü instanziieren
	pause_menu = PauseMenuScene.instantiate()
	add_child(pause_menu)
	pause_menu.visible = false
	overlay.visible = false

	# Startpositionen erfassen und initiale Formen als erste Pool-Entnahmen zählen
	var idx: int = 0
	for shape in $ShapesContainer.get_children():
		if not shape.name.begins_with("zielbereich") and shape.has_signal("form_completed"):
			original_positions.append(shape.global_position)
			shape.start_index = idx
			shape.connect("form_completed", Callable(self, "_on_form_completed"))
			# Entferne initial gezeigte Form aus Pool
			var stype: String = shape.shape_type
			shape_pool.erase(stype)
			idx += 1
		else:
			print("Signal nicht verbunden für Node:", shape.name)

func _on_form_completed(caller) -> void:
	# Gesamtzähler erhöhen
	total_locked += 1
	print("Form gelockt – Gesamt: %d" % total_locked)

	# Spawn, solange Pool nicht leer
	if spawn_next(caller.start_index):
		# Nachspawnen erfolgreich
		pass
	# Levelende nach 9 Locks (Pool leer oder total_locked>=9)
	if total_locked >= 9 and shape_pool.size() == 0:
		print("Alle Formen gelockt – Level complete!")
		show_level_complete()

func spawn_next(at_index: int) -> bool:
	if shape_pool.size() == 0:
		return false
	# Zufällige Auswahl aus Pool und entfernen
	var i: int = randi() % shape_pool.size()
	var choice: String = shape_pool[i]
	shape_pool.remove_at(i)

	# Instanziieren und positionieren
	var scene: PackedScene = load(base_paths[choice])
	var inst: Node2D = scene.instantiate() as Node2D
	$ShapesContainer.add_child(inst)
	inst.global_position = original_positions[at_index]
	inst.start_index = at_index
	inst.connect("form_completed", Callable(self, "_on_form_completed"))
	print("%s neu gespawnt an Position %d" % [choice.capitalize(), at_index])
	return true

func show_level_complete() -> void:
	overlay.visible = true
	print("Overlay sichtbar: Level abgeschlossen!")

func toggle_pause() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_menu.hide()
	else:
		get_tree().paused = true
		pause_menu.show()

func _input(event) -> void:
	if event.is_action_pressed("ui_pause"):
		toggle_pause()

func _on_pausebutton_pressed() -> void:
	toggle_pause()
