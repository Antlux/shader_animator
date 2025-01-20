extends Camera2D

@export var zoom_label: Label


func _ready() -> void:
	zoom = get_max_zoom_out()
	Global.export_settings.changed.connect(_on_export_settings_changed)
	self.get_viewport().size_changed.connect(_on_size_changed)
	change_zoom(zoom)


func change_zoom(new_zoom: Vector2):
	zoom = new_zoom
	zoom_label.text = "ZOOM/SCALE = (%.2f %.2f)" % [zoom.x, zoom.y]


func get_limit_rect() -> Rect2:
	var resolution = Vector2(Global.export_settings.resolution)
	var half = resolution / 2.0
	
	var rect = self.get_viewport_rect()
	var scaled_size : Vector2 = rect.size / zoom
	var vmin = -scaled_size / 2.0
	var vmax = vmin + scaled_size
	
	var aspect_ratio = Vector2(maxf(rect.size.x / rect.size.y, 1.0), maxf(rect.size.y / rect.size.x, 1.0))
	
	var min = vmin / (Vector2.ONE + .1 * Vector2.ONE / aspect_ratio) + half
	var max = vmax / (Vector2.ONE + .1 * Vector2.ONE / aspect_ratio) - half
	
	return Rect2(min.min(max), min.max(max))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("pan"):
			
			var limit_rect := get_limit_rect()
			var min := limit_rect.position
			var max := limit_rect.size
			
			position.x = clamp(position.x - event.relative.x / zoom.x, min.x , max.x)
			position.y = clamp(position.y - event.relative.y / zoom.y, min.y, max.y)
			


func get_max_zoom_out() -> Vector2:
	var ratio := (Vector2(Global.export_settings.resolution) * 1.1) / (self.get_viewport_rect().size / zoom)
	var f = maxf(ratio.x, ratio.y)
	return zoom / f


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("zoom_in"):
		
		var first = get_local_mouse_position()
		change_zoom(zoom * (Vector2.ONE * 1.2))
		var second = get_local_mouse_position()
		var mouse_delta = second - first
		
		var limit_rect := get_limit_rect()
		var min := limit_rect.position
		var max := limit_rect.size
		
		position.x = clampf(position.x - mouse_delta.x, min.x, max.x)
		position.y = clampf(position.y - mouse_delta.y, min.y, max.y)
	if Input.is_action_just_pressed("zoom_out"):
		
		var first = get_local_mouse_position()
		change_zoom((zoom / (Vector2.ONE * 1.2)).max(get_max_zoom_out()))
		var second = get_local_mouse_position()
		var mouse_delta = second - first
		
		var limit_rect := get_limit_rect()
		var min := limit_rect.position
		var max := limit_rect.size
		
		position.x = clampf(position.x - mouse_delta.x, min.x, max.x)
		position.y = clampf(position.y - mouse_delta.y, min.y, max.y)

func _on_size_changed() -> void:
	await get_tree().process_frame
	change_zoom(zoom.max(get_max_zoom_out()))
	
	var limit_rect := get_limit_rect()
	var min := limit_rect.position
	var max := limit_rect.size
	
	position.x = clampf(position.x, min.x, max.x)
	position.y = clampf(position.y, min.y, max.y)


func _on_export_settings_changed() -> void:
	change_zoom(zoom.max(get_max_zoom_out()))
	
	var limit_rect := get_limit_rect()
	var min := limit_rect.position
	var max := limit_rect.size
	
	position.x = clampf(position.x, min.x, max.x)
	position.y = clampf(position.y, min.y, max.y)
