extends Popup


func _on_weiter_pressed() -> void:
	get_parent().toggle_pause()


func _on_zurück_zum_hauptmenü_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_level_neustarten_pressed() -> void:
	var current_scene_path := get_tree().current_scene.scene_file_path
	print("🔁 Neustart: Lade aktuelle Szene neu:", current_scene_path)

	var err := get_tree().change_scene_to_file(current_scene_path)
	if err != OK:
		push_error("❌ Neustart fehlgeschlagen: %d" % err)
