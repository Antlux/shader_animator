class_name RenderView extends SubViewportContainer

signal camera_zoom_changed
signal camera_position_changed

@export var camera: Camera2D


func _ready() -> void:
	camera.zoom = get_max_zoom_out()
	camera.position = ShaderAnimationRenderer.size / 2.0
	
	ShaderAnimationRenderer.resized.connect(_on_render_resized)
	camera.get_viewport().size_changed.connect(_on_size_changed)
	change_zoom(camera.zoom)


func change_position(new_position: Vector2) -> void:
	camera.position = new_position
	camera_position_changed.emit()

func change_zoom(new_zoom: Vector2) -> void:
	camera.zoom = new_zoom
	camera_zoom_changed.emit()


#func get_limit_rect() -> Rect2:
	#var resolution = Vector2(Render.size)
	#var half = resolution / 2.0
	#
	#var rect = camera.get_viewport_rect()
	#var scaled_size : Vector2 = rect.size / camera.zoom
	#var vmin = -scaled_size / 2.0
	#var vmax = vmin + scaled_size
	#
	#var aspect_ratio = Vector2(maxf(rect.size.x / rect.size.y, 1.0), maxf(rect.size.y / rect.size.x, 1.0))
	#
	#var rect_min = vmin / (Vector2.ONE + .1 * Vector2.ONE / aspect_ratio) + half
	#var rect_max = vmax / (Vector2.ONE + .1 * Vector2.ONE / aspect_ratio) - half
	#
	#return Rect2(rect_min.min(rect_max), rect_min.max(rect_max))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("pan"):
			
			var input := Vector2(event.relative) / camera.zoom
			
			change_position(camera.position - input)


func _process(_delta: float) -> void:
	if not get_rect().has_point(get_local_mouse_position()):
		return
	
	if Input.is_action_just_pressed("zoom_in"):
		var start_pos := get_viewpos(get_local_mouse_position())
		change_zoom(camera.zoom * (Vector2.ONE * 1.2))
		var end_pos := get_viewpos(get_local_mouse_position())
		
		camera.position -= end_pos - start_pos
		
	if Input.is_action_just_pressed("zoom_out"):
		var start_pos := get_viewpos(get_local_mouse_position())
		change_zoom((camera.zoom / (Vector2.ONE * 1.2)).max(get_max_zoom_out()))
		var end_pos := get_viewpos(get_local_mouse_position())
		
		camera.position -= end_pos - start_pos


func get_viewpos(pos: Vector2) -> Vector2:
	# Gets the position of the mouse relative to the center of the view
	var pos_relative_center_view := pos - camera.get_viewport_rect().size / 2.0
	
	# Scales it to the camera zoom
	var scaled_pos := (pos_relative_center_view / camera.zoom)
	
	# Offsets it by the camera position in view world
	var relative_pos := camera.position + scaled_pos
	return relative_pos


func get_max_zoom_out() -> Vector2:
	var ratio := (Vector2(ShaderAnimationRenderer.size) * 1.5) / (camera.get_viewport_rect().size / camera.zoom)
	var f = maxf(ratio.x, ratio.y)
	return (camera.zoom / f).min(Vector2.ONE)


func _on_size_changed() -> void:
	await get_tree().process_frame
	change_zoom(camera.zoom.max(get_max_zoom_out()))


func _on_render_resized(from: Vector2i, to: Vector2i) -> void:
	var delta := (to / 2.0) - (from / 2.0)
	change_position(camera.position + delta)
	prints(from, to, delta)
	#change_zoom(camera.zoom.max(get_max_zoom_out()))
	
