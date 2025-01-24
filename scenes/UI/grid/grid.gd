extends Control

@export var camera: Camera2D
@export var x_axis_color := Color.GREEN_YELLOW
@export var y_axis_color := Color.ORANGE_RED
@export var offset := Vector2(5, -5)


var ci := get_canvas_item()
var surface := RenderingServer.canvas_item_create()

func _ready() -> void:
	RenderingServer.canvas_item_set_parent(surface, ci)

func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var viewport_rect := camera.get_viewport_rect()
	var v_size := viewport_rect.size / camera.zoom
	var v_pos := camera.position + position
	var vmin := - v_size / 2.0 + v_pos + camera.offset
	var vmax := v_size / 2.0 + v_pos + camera.offset
	var limit_rect := Rect2(vmin, vmax)
	
	var cull_rect = Rect2 (
		position.min(vmin),
		(position + size).max(vmax)
	)
	
	RenderingServer.canvas_item_set_custom_rect(ci, true, cull_rect)
	
	var ticks_interval := .5
	var major_points := PackedVector2Array()
	var minor_points := PackedVector2Array()
	var draw_minor_lines := camera.zoom.x >= 8.0
	var mark_pixel_lines := camera.zoom.x >= 128.0
	var rate := nearest_po2(roundi(maxf(64.0 / (ticks_interval * camera.zoom.x), 1.0)))
	
	RenderingServer.canvas_item_clear(surface)
	RenderingServer.canvas_item_set_transform(surface,
			Transform2D(0, Vector2(1, 1) / camera.zoom, 0, Vector2.ZERO))
	
	for x in range(vmin.x, vmax.x + rate, rate):
		x -= fmod(x, rate)
		var zero := maxf(0.0, vmin.y + (offset.y + 32) / camera.zoom.x)
		get_theme_default_font().draw_string(surface, Vector2(x , zero) * camera.zoom + offset, "%s" % x)
		if not is_zero_approx(x):
			minor_points.append_array([Vector2(x, vmin.y), Vector2(x, vmax.y)])
	for y in range(vmin.y, vmax.y + rate, rate):
		y -= fmod(y, rate)
		var zero := maxf(0.0, vmin.x)
		get_theme_default_font().draw_string(surface, Vector2(zero , y) * camera.zoom + offset, "%s" % y, )
		if not is_zero_approx(y):
			minor_points.append_array([Vector2(vmin.x, y), Vector2(vmax.x, y)])
	
	
	
	#RenderingServer.canvas_item_add_multiline(ci, minor_points,)
	draw_multiline(minor_points, Color.GRAY)
	draw_line(Vector2(vmin.x, 0.0), Vector2(vmax.x, 0.0), x_axis_color, 2.0 / camera.zoom.x)
	draw_line(Vector2(0.0, vmin.y), Vector2(0.0, vmax.y), y_axis_color, 2.0 / camera.zoom.x)
	#RenderingServer.canvas_item_add_line(ci, Vector2(vmin.x, 0.0), Vector2(vmax.x, -0.0), Color.GREEN_YELLOW, 2.0 / camera.zoom.x)
	#RenderingServer.canvas_item_add_line(ci, Vector2(0.0, vmin.y), Vector2(0.0, vmax.y), Color.ORANGE_RED, 2.0 / camera.zoom.x)
