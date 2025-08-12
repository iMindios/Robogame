extends Node

# Wird über Project → Project Settings → AutoLoad als "Transition" registriert
@onready var overlay_scene := preload("res://scenes/leveltween.tscn")

func _ready() -> void:
	print("[TransitionManager] Ready, overlay_scene =", overlay_scene)

func transition_to(path: String) -> void:
	# Debug-Ausgabe, damit wir sehen, ob hier jeder Klick ankommt
	print("[TransitionManager] transition_to called with:", path)

	# 1) Jedes Mal eine frische Instanz holen
	var overlay := overlay_scene.instantiate() as CanvasLayer
	print("[TransitionManager]  Instantiated overlay:", overlay)

	# 2) Sofort ins Root einhängen
	get_tree().get_root().add_child(overlay)

	# 3) Deferred starten, damit der Overlay-CanvasLayer komplett initialisiert ist
	overlay.call_deferred("start_transition", path)
