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
	
	var rect_min = vmin / (Vector2.ONE + .1 * Vector2.ONE / aspect_ratio) + half
	var rect_max = vmax / (Vector2.ONE + .1 * Vector2.ONE / aspect_ratio) - half
	
	return Rect2(rect_min.min(rect_max), rect_min.max(rect_max))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("pan"):
			
			var limit_rect := get_limit_rect()
			var rect_min := limit_rect.position
			var rect_max := limit_rect.size
			
			var input := Vector2(event.relative) / camera.zoom
			
			camera.position.x = camera.position.x - input.x
			camera.position.y = camera.position.y - input.y



func _process(_delta: float) -> void:
	if not get_rect().has_point(get_local_mouse_position()):
		return
	
	if Input.is_action_just_pressed("zoom_in"):
		change_zoom(camera.zoom * (Vector2.ONE * 1.2))
		
	if Input.is_action_just_pressed("zoom_out"):
		change_zoom((camera.zoom / (Vector2.ONE * 1.2)).max(get_max_zoom_out()))




func get_max_zoom_out() -> Vector2:
	var ratio := (Vector2(Global.export_settings.resolution) * 1.1) / (camera.get_viewport_rect().size / camera.zoom)
	var f = maxf(ratio.x, ratio.y)
	return (camera.zoom / f).min(Vector2.ONE)


func _on_size_changed() -> void:
	await get_tree().process_frame
	change_zoom(camera.zoom.max(get_max_zoom_out()))



func _on_export_settings_changed() -> void:
	change_zoom(camera.zoom.max(get_max_zoom_out()))
	
	camera.offset = Global.export_settings.resolution / 2.0
