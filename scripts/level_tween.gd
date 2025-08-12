extends CanvasLayer

func start_transition(path: String) -> void:
	# Overlay-Control holen
	var overlay_control := $Overlay as Control
	if not overlay_control:
		push_error("❌ [LevelTween] Overlay-Node nicht gefunden!")
		return

	# AnimationPlayer holen
	var anim_player := overlay_control.get_node("AnimationPlayer") as AnimationPlayer
	if not anim_player:
		push_error("❌ [LevelTween] AnimationPlayer nicht gefunden!")
		return

	# Debug: Pfad und Existenz prüfen
	print("[LevelTween] Pfad zum Laden: %s" % path)
	if not ResourceLoader.exists(path, "PackedScene"):
		push_error("❌ [LevelTween] Szene existiert nicht: %s" % path)
		return

	# Fade-In abspielen
	overlay_control.visible = true
	print("[LevelTween] Fade-In start")
	anim_player.play("Fade_in")
	await anim_player.animation_finished
	print("[LevelTween] Fade-In fertig")

	# Szenenwechsel synchron ausführen und Fehler prüfen
	print("[LevelTween] Wechsel zu Szene: %s" % path)
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("❌ change_scene fehlgeschlagen: %d" % err)
		return

	# Kurze Wartezeit, bis die neue Szene bereit ist
	await get_tree().process_frame

	# Fade-Out abspielen
	if anim_player.has_animation("Fade_out"):
		print("[LevelTween] Fade-Out start")
		anim_player.play("Fade_out")
		await anim_player.animation_finished
		print("[LevelTween] Fade-Out fertig")
	else:
		push_error("❌ AnimationPlayer kennt keine 'Fade_out'-Animation!")

	# Overlay entfernen
	queue_free()
