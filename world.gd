extends Node3D

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Restart"): 
		restart()
	if Input.is_action_just_pressed("Menu"):
		var menuScene = load("res://MainMenu.tscn")
		get_tree().change_scene_to_packed(menuScene)

func restart():
	var scene = load("res://Level" + str(get_meta("level")) + ".tscn")
	get_tree().change_scene_to_packed(scene)
	
