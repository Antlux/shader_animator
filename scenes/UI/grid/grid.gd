extends Control

@export var camera: Camera2D
var ci := get_canvas_item()
var surface := RenderingServer.canvas_item_create()


func _process(delta: float) -> void:
		queue_redraw()


func _draw() -> void:
	var viewport_rect := camera.get_viewport_rect()
	var v_size := viewport_rect.size / camera.zoom
	var v_pos := camera.position + position
	var vmin := - v_size / 2.0 + v_pos + camera.offset
	var vmax := v_size / 2.0 + v_pos + camera.offset
	var limit_rect := Rect2(vmin, vmax)
	
	var ticks_interval := .5
	var major_points := PackedVector2Array()
	var minor_points := PackedVector2Array()
	var draw_minor_lines := camera.zoom.x >= 8.0
	var mark_pixel_lines := camera.zoom.x >= 128.0
	var rate := nearest_po2(roundi(maxf(64.0 / (ticks_interval * camera.zoom.x), 1.0)))
	
	for x in range(vmin.x, vmax.x + rate, rate):
		x -= fmod(x, rate)
		minor_points.append_array([Vector2(x, vmin.y), Vector2(x, vmax.y)])
	for y in range(vmin.y, vmax.y + rate, rate):
		y -= fmod(y, rate)
		minor_points.append_array([Vector2(vmin.x, y), Vector2(vmax.x, y)])
	
	for x in range(vmin.x, vmax.x + rate, rate):
		x -= fmod(x, rate)
	for y in range(vmin.y, vmax.y + rate, rate):
		y -= fmod(y, rate)
		minor_points.append_array([Vector2(vmin.x, y), Vector2(vmax.x, y)])
	
	
	#RenderingServer.canvas_item_add_multiline(ci, minor_points,)
	draw_multiline(minor_points, Color.GRAY)
	draw_line(Vector2(vmin.x, 0.0), Vector2(vmax.x, 0.0), Color.GREEN_YELLOW, 2.0 / camera.zoom.x)
	draw_line(Vector2(0.0, vmin.y), Vector2(0.0, vmax.y), Color.ORANGE_RED, 2.0 / camera.zoom.x)
	#RenderingServer.canvas_item_add_line(ci, Vector2(vmin.x, 0.0), Vector2(vmax.x, -0.0), Color.GREEN_YELLOW, 2.0 / camera.zoom.x)
	#RenderingServer.canvas_item_add_line(ci, Vector2(0.0, vmin.y), Vector2(0.0, vmax.y), Color.ORANGE_RED, 2.0 / camera.zoom.x)
