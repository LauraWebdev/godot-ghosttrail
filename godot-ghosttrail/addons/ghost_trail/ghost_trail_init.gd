extends Node

@export var save_path := "res://ghost_trail/last_run.tres"
var ghost : GhostTrailData

func _enter_tree():
	if not OS.is_debug_build():
		return
	if Engine.is_editor_hint():
		return
		
	ghost = GhostTrailData.new()

func _exit_tree():
	if not OS.is_debug_build():
		return
	if Engine.is_editor_hint():
		return
		
	ResourceSaver.save(ghost, save_path)
