extends Node2D

@export var interval := 0.05

var _timer := 0.0
var _positions := PackedVector2Array()
var _time := 0.0

var _data_entry: GhostTrailDataEntry

func _enter_tree():
	if not OS.is_debug_build():
		return
	if Engine.is_editor_hint():
		return
		
	_data_entry = GhostTrailDataEntry.new()
	_data_entry.scene_path = get_tree().current_scene.scene_file_path

func _process(delta):
	if not OS.is_debug_build():
		return
	if Engine.is_editor_hint():
		return

	_timer += delta
	_time += delta

	if _timer >= interval:
		_timer = 0
		_positions.append(global_position)

func _exit_tree():
	if not OS.is_debug_build():
		return
	if Engine.is_editor_hint():
		return
		
	_data_entry.positions.append_array(_positions)
	GhostTrailInit.ghost.scenes.append(_data_entry)
