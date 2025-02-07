class_name Grid extends Control

@export var unit_font: FontFile

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
	
	#var font := get_theme_default_font()
	
	
	RenderingServer.canvas_item_clear(surface)
	RenderingServer.canvas_item_set_transform(surface,
		Transform2D(0, Vector2(1, 1) / camera.zoom, 0, Vector2.ZERO)
	)
	
	for x in range(snappedi(vmin.x, rate), snappedi(vmax.x + rate, rate), rate):
		var x_unit_rect := Rect2() 
		
		if draw_grid_units:
			var unit_text := "%s" % x
			x_unit_rect = get_string_rect(unit_text, unit_font, 16)
			unit_font.draw_string(surface, Vector2(x, vmin.y) * zoom + Vector2(-x_unit_rect.size.x / 2.0, x_unit_rect.size.y), unit_text)
		
		if draw_grid_lines:
			draw_vertical_line(Vector2(x, vmin.y) * zoom, Vector2(x, vmax.y) * zoom, x_unit_rect.size.y)
		
	for y in range(snappedi(vmin.y, rate), snappedi(vmax.y + rate, rate), rate):
		var y_unit_rect := Rect2() 
		if draw_grid_units:
			var unit_text := "%s" % y 
			y_unit_rect = get_string_rect(unit_text, unit_font , 16)
			var pos := Vector2(vmin.x, y) * zoom + Vector2.UP * (y_unit_rect.size.y / 2.0)
			unit_font.draw_string(surface, pos + Vector2.DOWN * y_unit_rect.size.y, unit_text)
		
		if draw_grid_lines:
			draw_horizontal_line(Vector2(vmin.x, y) * zoom, Vector2(vmax.x, y) * zoom, y_unit_rect.size)
	
	
	var unit_rect := Rect2()
	if draw_grid_units:
		var unit_text := "%s" % 0
		unit_rect = get_string_rect(unit_text, unit_font, 16)
	
	if draw_x_axis:
		draw_horizontal_line(Vector2(vmin.x, 0) * zoom.x, Vector2(vmax.x, 0) * zoom.x, unit_rect.size, x_axis_color, 2.0, 3.0)
	
	if draw_y_axis:
		draw_vertical_line(Vector2(0, vmin.y) * zoom, Vector2(0, vmax.y) * zoom, unit_rect.size.y, y_axis_color, 2.0, 3.0)


func draw_horizontal_line(start: Vector2, end: Vector2, unit_rect_size: Vector2, color := grid_line_color, width := 1.0, radius:= 2.0) -> void:
	var line_start := start + Vector2.RIGHT * (unit_rect_size.x + padding.x + radius)
	var line_end := end
	RenderingServer.canvas_item_add_line(surface, line_start, line_end, color, width)
	RenderingServer.canvas_item_add_circle(surface, line_start, radius, color)

func draw_vertical_line(start: Vector2, end: Vector2, unit_rect_size_y: float, color := grid_line_color, width := 1.0, radius:= 2.0) -> void:
	var line_start := start + Vector2.DOWN * (unit_rect_size_y + padding.y + radius)
	var line_end := end
	RenderingServer.canvas_item_add_line(surface, line_start, line_end, color, width)
	RenderingServer.canvas_item_add_circle(surface, line_start, radius, color)


func get_string_rect(text: String, font: Font, font_size: int) -> Rect2:
	var text_server := TextServerManager.get_primary_interface()
	var paragraph := TextParagraph.new()
	paragraph.add_string(text, font, font_size)
	var line := TextLine.new()
	line.add_string(text, font, font_size)
	var line_rid := line.get_rid()
	
	var ascent := line.get_line_ascent()
	var glyphs := text_server.shaped_text_get_glyphs(line_rid)
	
	
	var rects: Array[Rect2] = []
	var x := 0
	for idx in glyphs.size():
		var glyph := glyphs[idx]
		var glyph_font_rid: RID = glyph.get('font_rid', RID())
		var glyph_font_size := Vector2i(glyph.get('font_size', 8), 0)
		var glyph_index: int = glyph.get('index', -1)
		var glyph_offset := text_server.font_get_glyph_offset(glyph_font_rid, glyph_font_size, glyph_index)
		var glyph_advance: int = glyph.get('advance', 0)
		var glyph_size := text_server.font_get_glyph_size(glyph_font_rid, glyph_font_size, glyph_index)
		glyph_size.x -= maxf(0, glyph_size.x - glyph_advance)
		var glyph_rect := Rect2(Vector2(x, ascent) + glyph_offset, glyph_size)
		if glyph_rect.has_area():
			rects.append(glyph_rect)
		x += glyph_advance
	

	var rect : Rect2 = rects.pop_front() if not rects.is_empty() else Rect2()
	
	for r in rects:
		rect = rect.merge(r)
	
	return rect


func _on_camera_position_changed() -> void:
	queue_redraw()

func _on_camera_zoom_changed() -> void:
	queue_redraw()
