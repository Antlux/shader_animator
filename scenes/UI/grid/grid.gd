class_name Grid extends Control

@export var camera: Camera2D
@export var x_axis_color := Color.GREEN_YELLOW
@export var y_axis_color := Color.ORANGE_RED
@export var grid_line_color := Color.GRAY
@export var grid_units_color := Color.WHITE
@export var offset := Vector2(-2, -5)

@export var draw_x_axis: bool = true
@export var draw_y_axis: bool = true
@export var draw_grid_line: bool = true
@export var draw_grid_units: bool = true



var ci := get_canvas_item()
var surface := RenderingServer.canvas_item_create()

func _ready() -> void:
	RenderingServer.canvas_item_set_parent(surface, ci)

func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var zoom := camera.zoom
	
	var viewport_rect := camera.get_viewport_rect()
	var v_size := viewport_rect.size / zoom
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
	var draw_minor_lines := zoom.x >= 8.0
	var mark_pixel_lines := zoom.x >= 128.0
	var rate := nearest_po2(roundi(maxf(64.0 / (ticks_interval * zoom.x), 1.0)))
	
	RenderingServer.canvas_item_clear(surface)
	
	var font := get_theme_default_font()
	
	for x in range(vmin.x - rate, vmax.x + rate, rate):
		x -= fmod(x, rate)
		
		var unit_text := "%s" % x
		var string_size := font.get_string_size(unit_text, 0, -1, 16)
		var factor := pow(sin(inverse_lerp(vmin.x, vmax.x - (string_size.x + offset.x) / zoom.x, x) * PI), 0.2)
		var zero := clampf(0.0, vmin.y + (string_size.y - offset.y) / zoom.y, vmax.y)
		font.draw_string(surface, Vector2(x, zero) * zoom - Vector2(string_size.x, 0) + offset, "%s" % x, 0, -1, 16, grid_units_color * factor)
		
		if draw_grid_line:
			minor_points.append_array([Vector2(x, vmin.y), Vector2(x, vmax.y)])
	
	for y in range(vmin.y - rate, vmax.y + rate, rate):
		y -= fmod(y, rate)
		
		var unit_text := "%s" % y
		var string_size := font.get_string_size(unit_text, 0, -1, 16)
		var factor := pow(sin(inverse_lerp(vmin.y + (string_size.y + offset.y) / zoom.y, vmax.y, y) * PI), 0.2)
		var zero := clampf(0.0, vmin.x + (string_size.x - offset.x * 2.0) / zoom.x, vmax.x)
		font.draw_string(surface, Vector2(zero, y) * zoom - Vector2(string_size.x, 0) + offset, "%s" % y, 0, -1, 16, grid_units_color * factor)
		
		if draw_grid_line:
			minor_points.append_array([Vector2(vmin.x, y), Vector2(vmax.x, y)])
	
	RenderingServer.canvas_item_set_transform(surface,
			Transform2D(0, Vector2(1, 1) / camera.zoom, 0, Vector2.ZERO))
	
	if draw_grid_line:
		draw_multiline(minor_points, grid_line_color)
	draw_line(Vector2(vmin.x, 0.0), Vector2(vmax.x, 0.0), x_axis_color, 2.0 / camera.zoom.x)
	draw_line(Vector2(0.0, vmin.y), Vector2(0.0, vmax.y), y_axis_color, 2.0 / camera.zoom.x)
