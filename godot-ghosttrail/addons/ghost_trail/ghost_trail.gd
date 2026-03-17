@tool
extends EditorPlugin

const GhostTrailRecorder = preload("uid://d1kskekeri5mx")

var ghost: GhostTrailData
var ghost_path := "res://ghost_trail/last_run.tres"

var reload_ghost_data_button: Button
var clear_ghost_data_button: Button
var was_playing: bool = false

func _enable_plugin():
	pass

func _disable_plugin():
	pass
	
func _process(delta):
	# Automatically load ghost
	var is_playing = EditorInterface.is_playing_scene()
	if was_playing and !is_playing:
		await get_tree().create_timer(0.1).timeout
		load_ghost()
	was_playing = is_playing

func _enter_tree():
	# Data
	ensure_ghost_folder()
	add_custom_type(
		"GhostTrailRecorder",
		"Node2D",
		GhostTrailRecorder,
		null
	)
	add_autoload_singleton("GhostTrailInit", "res://addons/ghost_trail/ghost_trail_init.gd")
	
	# Runtime Controls
	reload_ghost_data_button = Button.new()
	reload_ghost_data_button.text = "Reload Ghost"
	reload_ghost_data_button.connect("pressed", load_ghost)
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, reload_ghost_data_button)
	
	clear_ghost_data_button = Button.new()
	clear_ghost_data_button.text = "Clear Ghost"
	clear_ghost_data_button.connect("pressed", unload_ghost)
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, clear_ghost_data_button)
	
	EditorInterface.get_editor_main_screen()
	scene_changed.connect(_on_scene_changed)

func _exit_tree():
	remove_custom_type("GhostTrailRecorder")
	remove_autoload_singleton("GhostTrailInit")
	
	unload_ghost()
	
	if reload_ghost_data_button:
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, reload_ghost_data_button)
		reload_ghost_data_button.queue_free()
		
	if clear_ghost_data_button:
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, clear_ghost_data_button)
		clear_ghost_data_button.queue_free()
	
func ensure_ghost_folder():
	var path = "res://ghost_trail"

	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
		EditorInterface.get_resource_filesystem().scan()

func load_ghost():
	reload_ghost_data_button.disabled = true
	clear_ghost_data_button.disabled = true
	unload_ghost()
	
	if !ResourceLoader.exists(ghost_path):
		return
		
	ghost = load(ghost_path)
	if ghost == null:
		return
	
	var edited_scene_root = EditorInterface.get_edited_scene_root()
	if edited_scene_root == null:
		return
	var current_scene_name = edited_scene_root.scene_file_path
	
	for scene in ghost.scenes:
		if scene.scene_path == current_scene_name:
			reload_ghost_data_button.disabled = false
			clear_ghost_data_button.disabled = false

	for scene_index in ghost.scenes.size():
		var scene = ghost.scenes[scene_index]

		if scene.scene_path == current_scene_name:
			var ghost_path_node = Path2D.new()
			ghost_path_node.add_to_group("ghost_trail")
			var new_curve = Curve2D.new()

			# Determine previous and next scene paths
			var prev_scene_path = null
			var next_scene_path = null

			if scene_index > 0:
				prev_scene_path = ghost.scenes[scene_index - 1].scene_path

			if scene_index < ghost.scenes.size() - 1:
				next_scene_path = ghost.scenes[scene_index + 1].scene_path
				
			var last_point = null
			for i in scene.positions.size():
				var point = scene.positions[i]
				# Fixes "Zero interval"
				if last_point == null or point != last_point:
					new_curve.add_point(point)
				last_point = point

				# FIRST position → show previous scene
				if i == 0 and prev_scene_path != null and prev_scene_path != current_scene_name:
					_create_scene_label(point, prev_scene_path)

				# LAST position → show next scene
				if i == scene.positions.size() - 1 and next_scene_path != null and next_scene_path != current_scene_name:
					_create_scene_label(point, next_scene_path)

			ghost_path_node.curve = new_curve
			EditorInterface.get_editor_viewport_2d().add_child(ghost_path_node)

func unload_ghost():
	for child in EditorInterface.get_editor_viewport_2d().get_children():
		if child.is_in_group("ghost_trail"):
			child.queue_free()
			
func _on_scene_changed(_scene_root):
	load_ghost()
	
func _create_scene_label(position: Vector2, text: String) -> void:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = position
	label.z_index = 1000
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	label.add_to_group("ghost_trail")
	EditorInterface.get_editor_viewport_2d().add_child(label)
