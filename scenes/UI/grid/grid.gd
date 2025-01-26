class_name Grid extends Control

#@export var font: FontFile

@export var render_view: RenderView

@export var camera: Camera2D
@export var x_axis_color := Color.ORANGE_RED
@export var y_axis_color := Color.GREEN_YELLOW
@export var grid_line_color := Color.GRAY
@export var grid_units_color := Color.WHITE

@export var padding := Vector2(2, 2)

@export var draw_x_axis: bool = true:
	set(value):
		draw_x_axis = value
		queue_redraw()
@export var draw_y_axis: bool = true:
	set(value):
		draw_y_axis = value
		queue_redraw()
@export var draw_grid_lines: bool = true:
	set(value):
		draw_grid_lines = value
		queue_redraw()
@export var draw_grid_units: bool = true:
	set(value):
		draw_grid_units = value
		queue_redraw()


var ci := get_canvas_item()
var surface := RenderingServer.canvas_item_create()


func _ready() -> void:
	RenderingServer.canvas_item_set_parent(surface, ci) # For drawing of grid units
	render_view.camera_position_changed.connect(_on_camera_position_changed)
	render_view.camera_zoom_changed.connect(_on_camera_zoom_changed)


func _draw() -> void:
	var zoom := camera.zoom
	var viewport_rect := camera.get_viewport_rect()
	var v_size := viewport_rect.size / zoom
	var v_pos := camera.position - v_size / 2.0 + camera.offset
	var vmin := v_pos
	var vmax := v_pos + v_size 
	var ticks_interval := .5
	var rate := nearest_po2(roundi(maxf(64.0 / (ticks_interval * zoom.x), 1.0)))
	
	var font := get_theme_default_font()
	
	
	RenderingServer.canvas_item_clear(surface)
	
	
	for x in range(snappedi(vmin.x, rate), snappedi(vmax.x + rate, rate), rate):
		var unit_rect := Rect2() 
		
		if draw_grid_units:
			var unit_text := "%s" % x
			unit_rect = get_string_rect(unit_text, font, 16)
			font.draw_string(surface, Vector2(x, vmin.y) * zoom + Vector2(-unit_rect.size.x / 2.0, unit_rect.size.y), unit_text)
		
		if draw_grid_lines:
			var radius := 2
			var line_start := Vector2(x, vmin.y) * zoom + Vector2.DOWN * (unit_rect.size.y + padding.y + radius)
			var line_end := Vector2(x, vmax.y) * zoom
			RenderingServer.canvas_item_add_line(surface, line_start, line_end, grid_line_color, 1)
			RenderingServer.canvas_item_add_circle(surface, line_start, radius, grid_line_color)
		
	for y in range(snappedi(vmin.y, rate), snappedi(vmax.y + rate, rate), rate):
		var unit_rect := Rect2() 
		if draw_grid_units:
			var unit_text := "%s" % y 
			unit_rect = get_string_rect(unit_text, font , 16)
			font.draw_string(surface, Vector2(vmin.x, y) * zoom + unit_rect.position, unit_text)
		
		if draw_grid_lines:
			var radius := 2
			var line_start := Vector2(vmin.x, y) * zoom + Vector2.RIGHT * (unit_rect.size.x + padding.x + radius)
			var line_end := Vector2(vmax.x, y) * zoom
			RenderingServer.canvas_item_add_line(surface, line_start, line_end, grid_line_color, 1)
			RenderingServer.canvas_item_add_circle(surface, line_start, radius, grid_line_color)
	
	var unit_rect := Rect2()
	if draw_grid_units:
		var unit_text := "%s" % 0
		unit_rect = get_string_rect(unit_text, font, 16)
	
	
	if draw_x_axis:
		var radius := 3
		var axis_start := Vector2(vmin.x, 0) * zoom + Vector2.RIGHT * (unit_rect.size.x + padding.x + radius)
		var axis_end := Vector2(vmax.x, 0) * zoom
		RenderingServer.canvas_item_add_line(surface, axis_start, axis_end, x_axis_color, 2)
		RenderingServer.canvas_item_add_circle(surface, axis_start, radius, x_axis_color)
	
	if draw_y_axis:
		var radius := 3
		var axis_start := Vector2(0, vmin.y) * zoom + Vector2.DOWN * (unit_rect.size.y + padding.y + radius)
		var axis_end := Vector2(0, vmax.y) * zoom
		RenderingServer.canvas_item_add_line(surface, axis_start, axis_end, y_axis_color, 2)
		RenderingServer.canvas_item_add_circle(surface, axis_start, radius, y_axis_color)
	
	
	RenderingServer.canvas_item_set_transform(surface,
		Transform2D(0, Vector2(1, 1) / camera.zoom, 0, Vector2.ZERO)
	)
	

func _on_camera_position_changed() -> void:
	queue_redraw()


func _on_camera_zoom_changed() -> void:
	queue_redraw()


func get_string_rect(text: String, font: Font, font_size: int) -> Rect2:
	var text_server := TextServerManager.get_primary_interface()
	var line := TextLine.new()
	line.add_string(text, font, font_size)
	var line_rid := line.get_rid()
	
	var ascent := line.get_line_ascent()
	var glyphs := text_server.shaped_text_get_glyphs(line_rid)
	
	var x := 0
	
	var rects: Array[Rect2] = []
	
	for glyph in glyphs:
		var glyph_font_rid: RID = glyph.get('font_rid', RID())
		var glyph_font_size := Vector2i(glyph.get('font_size', 8), 0)
		var glyph_index: int = glyph.get('index', -1)
		var glyph_offset := text_server.font_get_glyph_offset(glyph_font_rid, glyph_font_size, glyph_index)
		var glyph_size := text_server.font_get_glyph_size(glyph_font_rid, glyph_font_size, glyph_index)
		var glyph_rect := Rect2(Vector2(x, ascent) + glyph_offset, glyph_size)
		if glyph_rect.has_area():
			rects.append(glyph_rect)
		var glyph_advance: int = glyph.get('advance', 0)
		x += glyph_advance
	
	var rect := Rect2()
	if not rects.is_empty():
		rect = rects[0]
	
	for idx in range(1, rects.size()):
		rect = rect.merge(rects[idx])
	
	return rect
