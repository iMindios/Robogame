extends CanvasLayer

func _on_play_pressed() -> void:
	print(">>> START gedrückt!")
	var path := "res://scenes/levelselect/levelselect.tscn"
	print("Lade Szene:", path)
	var err = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("change_scene fehlgeschlagen: %s" % err)
		print("Error code:", err)
		
func _on_beenden_pressed() -> void:
	get_tree().quit()
