extends SubViewportContainer

signal camera_zoom_changed

@export var camera: Camera2D


func _ready() -> void:
	camera.zoom = get_max_zoom_out()
	camera.offset = Global.export_settings.resolution / 2.0
	Global.export_settings.changed.connect(_on_export_settings_changed)
	camera.get_viewport().size_changed.connect(_on_size_changed)
	change_zoom(camera.zoom)


func change_zoom(new_zoom: Vector2):
	camera.zoom = new_zoom
	camera_zoom_changed.emit()


func get_limit_rect() -> Rect2:
	var resolution = Vector2(Global.export_settings.resolution)
	var half = resolution / 2.0
	
	var rect = camera.get_viewport_rect()
	var scaled_size : Vector2 = rect.size / camera.zoom
	var vmin = -scaled_size / 2.0
	var vmax = vmin + scaled_size
	
	var aspect_ratio = Vector2(maxf(rect.size.x / rect.size.y, 1.0), maxf(rect.size.y / rect.size.x, 1.0))
	
	var min = vmin / (Vector2.ONE + .1 * Vector2.ONE / aspect_ratio) + half
	var max = vmax / (Vector2.ONE + .1 * Vector2.ONE / aspect_ratio) - half
	
	return Rect2(min.min(max), min.max(max))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("pan"):
			
			var limit_rect := get_limit_rect()
			var min := limit_rect.position
			var max := limit_rect.size
			
			var input := Vector2(event.relative) / camera.zoom
			
			camera.position.x = camera.position.x - input.x
			camera.position.y = camera.position.y - input.y
			camera.position.x = clamp(camera.position.x, min.x , max.x)
			camera.position.y = clamp(camera.position.y, min.y, max.y)


func _process(delta: float) -> void:
	if not get_rect().has_point(get_local_mouse_position()):
		return
	
	if Input.is_action_just_pressed("zoom_in"):
		var first = get_local_mouse_position()
		change_zoom(camera.zoom * (Vector2.ONE * 1.2))
		var second = get_local_mouse_position()
		var mouse_delta = second - first
		
		var limit_rect := get_limit_rect()
		var min := limit_rect.position
		var max := limit_rect.size
		
		camera.position.x = clamp(camera.position.x - mouse_delta.x, min.x , max.x)
		camera.position.y = clamp(camera.position.y - mouse_delta.y, min.y, max.y)
		camera.position.x = clamp(camera.position.x, min.x , max.x)
		camera.position.y = clamp(camera.position.y, min.y, max.y)
		
	if Input.is_action_just_pressed("zoom_out"):
		
		var first = get_local_mouse_position()
		change_zoom((camera.zoom / (Vector2.ONE * 1.2)).max(get_max_zoom_out()))
		var second = get_local_mouse_position()
		var mouse_delta = second - first
		
		var limit_rect := get_limit_rect()
		var min := limit_rect.position
		var max := limit_rect.size
		
		camera.position.x = clamp(camera.position.x - mouse_delta.x, min.x , max.x)
		camera.position.y = clamp(camera.position.y - mouse_delta.y, min.y, max.y)
		camera.position.x = clamp(camera.position.x, min.x , max.x)
		camera.position.y = clamp(camera.position.y, min.y, max.y)


func get_max_zoom_out() -> Vector2:
	var ratio := (Vector2(Global.export_settings.resolution) * 1.1) / (camera.get_viewport_rect().size / camera.zoom)
	var f = maxf(ratio.x, ratio.y)
	return (camera.zoom / f).min(Vector2.ONE)


func _on_size_changed() -> void:
	await get_tree().process_frame
	change_zoom(camera.zoom.max(get_max_zoom_out()))
	
	var limit_rect := get_limit_rect()
	var min := limit_rect.position
	var max := limit_rect.size
	
	camera.position.x = clamp(camera.position.x, min.x , max.x)
	camera.position.y = clamp(camera.position.y, min.y, max.y)


func _on_export_settings_changed() -> void:
	change_zoom(camera.zoom.max(get_max_zoom_out()))
	
	var limit_rect := get_limit_rect()
	var min := limit_rect.position
	var max := limit_rect.size
	
	position.x = clampf(position.x, min.x, max.x)
	position.y = clampf(position.y, min.y, max.y)
	
	camera.offset = Global.export_settings.resolution / 2.0
