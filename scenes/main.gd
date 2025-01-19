extends Node

@export var sub_viewport: SubViewport
@export var render: ColorRect
@export var settings_container: Control

@export var export_button : Button
@export var file_dialog: FileDialog
@export var progress_bar: ProgressBar

@onready var render_material: ShaderMaterial = render.material as ShaderMaterial

var rendering: bool = false

var current_time := 0.0

func _ready() -> void:
	setup_settings()
	export_button.pressed.connect(_on_export_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	progress_bar.max_value = 1.0


func _process(delta: float) -> void:
	
	var duration := Global.export_settings.duration
	var frame_count := Global.export_settings.frame_count
	
	if not rendering:
		current_time = fmod(current_time + delta, duration)
		var frame_rate = frame_count / duration;
		var value = floor(current_time * frame_rate) /  frame_rate
		progress_bar.value = value / duration
		render_material.set_shader_parameter("outside_time", value)


func setup_settings() -> void:
	for c in settings_container.get_children():
		c.queue_free()
	
	for p: Dictionary in render_material.shader.get_shader_uniform_list():
		var p_name : String = p["name"]
		var p_type : Variant.Type = p["type"]
		var p_hint := (p["hint_string"] as String).split(",")
		var p_usage : int = p["usage"]
		
		
		if p_usage == 64:
			settings_container.add_child(HSeparator.new())
			var group_label = Label.new()
			group_label.text = p_name.capitalize()
			settings_container.add_child(group_label)
			settings_container.add_child(HSeparator.new())
			continue
		
		if ["outside_time"].has(p_name):
			continue
		
		match p_type:
			TYPE_BOOL:
				pass
			TYPE_INT:
				int_parameter(p_name, p_hint)
			TYPE_FLOAT:
				float_parameter(p_name, p_hint)
			TYPE_VECTOR2:
				vector2_parameter(p_name, p_hint)
			TYPE_VECTOR2I:
				vector2i_parameter(p_name, p_hint)
			TYPE_COLOR:
				color_parameter(p_name, p_hint)

func int_parameter(p_name: String, hint : PackedStringArray) -> void:
	var p_label = Label.new()
	var p_spinbox = SpinBox.new()
	
	p_label.text = p_name
	if hint.size() > 1:
		p_spinbox.min_value = hint[0].to_float()
		p_spinbox.max_value = hint[1].to_float()
		p_spinbox.step = hint[2].to_float()
	else:
		p_spinbox.step = 1.0
		p_spinbox.min_value = -100
		p_spinbox.max_value = 100
	p_spinbox.value = render_material.get_shader_parameter(p_name)
	settings_container.add_child(p_label)
	settings_container.add_child(p_spinbox)
	p_spinbox.value_changed.connect(func(value: int): 
		render_material.set_shader_parameter(p_name, value)
		)

func float_parameter(p_name: String, hint : PackedStringArray) -> void:
	var p_label = Label.new()
	var p_spinbox = SpinBox.new()
	
	p_label.text = p_name
	if hint.size() > 1:
		p_spinbox.min_value = hint[0].to_float()
		p_spinbox.max_value = hint[1].to_float()
		p_spinbox.step = hint[2].to_float()
	else:
		p_spinbox.step = 0.01
	p_spinbox.value = render_material.get_shader_parameter(p_name) if render_material.get_shader_parameter(p_name) != null else 0.0
	settings_container.add_child(p_label)
	settings_container.add_child(p_spinbox)
	p_spinbox.value_changed.connect(func(value: float): 
		render_material.set_shader_parameter(p_name, value)
		)

func vector2_parameter(p_name: String, hint : PackedStringArray) -> void:
	var p_label := Label.new()
	var p_x_spinbox := SpinBox.new()
	var p_y_spinbox := SpinBox.new()
	p_label.text = p_name
	p_x_spinbox.value = render_material.get_shader_parameter(p_name).x if render_material.get_shader_parameter(p_name) != null else 0.0
	p_y_spinbox.value = render_material.get_shader_parameter(p_name).y if render_material.get_shader_parameter(p_name) != null else 0.0
	p_x_spinbox.step = 0.01
	p_y_spinbox.step = 0.01
	p_x_spinbox.prefix = "x:"
	p_y_spinbox.prefix = "y:"
	settings_container.add_child(p_label)
	settings_container.add_child(p_x_spinbox)
	#settings_container.add_child(Control.new())
	settings_container.add_child(p_y_spinbox)
	p_x_spinbox.value_changed.connect(func(value: float):
		var v = Vector2(value, render_material.get_shader_parameter(p_name).y if render_material.get_shader_parameter(p_name) != null else 0.0)
		render_material.set_shader_parameter(p_name, v)
		)
	p_y_spinbox.value_changed.connect(func(value: float): 
		var v = Vector2(render_material.get_shader_parameter(p_name).x if render_material.get_shader_parameter(p_name) != null else 0.0, value)
		render_material.set_shader_parameter(p_name, v)
		)

func vector2i_parameter(p_name: String, hint : PackedStringArray) -> void:
	var p_label := Label.new()
	var p_x_spinbox := SpinBox.new()
	var p_y_spinbox := SpinBox.new()
	p_label.text = p_name
	p_x_spinbox.value = render_material.get_shader_parameter(p_name).x if render_material.get_shader_parameter(p_name) != null else 0.0
	p_y_spinbox.value = render_material.get_shader_parameter(p_name).y if render_material.get_shader_parameter(p_name) != null else 0.0
	p_x_spinbox.step = 1.0
	p_y_spinbox.step = 1.0
	p_x_spinbox.prefix = "x:"
	p_y_spinbox.prefix = "y:"
	settings_container.add_child(p_label)
	settings_container.add_child(p_x_spinbox)
	#settings_container.add_child(Control.new())
	settings_container.add_child(p_y_spinbox)
	p_x_spinbox.value_changed.connect(func(value: float):
		var v = Vector2(value, render_material.get_shader_parameter(p_name).y if render_material.get_shader_parameter(p_name) != null else 0.0)
		render_material.set_shader_parameter(p_name, v)
		)
	p_y_spinbox.value_changed.connect(func(value: float): 
		var v = Vector2(render_material.get_shader_parameter(p_name).x if render_material.get_shader_parameter(p_name) != null else 0.0, value)
		render_material.set_shader_parameter(p_name, v)
		)

func color_parameter(p_name: String, p_hint: PackedStringArray) -> void:
	var p_label := Label.new()
	var p_color_picker_button := ColorPickerButton.new()
	p_label.text = p_name
	p_color_picker_button.color = render_material.get_shader_parameter(p_name) as Color
	p_color_picker_button.color_changed.connect(
		func(value): render_material.set_shader_parameter(p_name, value) 
			)
	p_color_picker_button.custom_minimum_size.y = 20.0
	settings_container.add_child(p_label)
	settings_container.add_child(p_color_picker_button)


func _on_export_pressed() -> void:
	file_dialog.root_subfolder
	file_dialog.show()

func _on_file_selected(file_path: String) -> void:
	var temp := file_path.rsplit("/", true, 1)
	var path := temp[0] + "/"
	var file_name := temp[1]
	
	Global.export_settings.export_path = file_path
	
	var duration :=  Global.export_settings.duration
	var frame_count := Global.export_settings.frame_count
	
	var frame_delay := duration / (frame_count)
	
	var captures: Array[Image] = []
	
	rendering = true
	
	for f in (frame_count):
		render_material.set_shader_parameter("outside_time", frame_delay * f)
		await get_tree().process_frame
		await get_tree().process_frame
		captures.append(sub_viewport.get_texture().get_image())
	
	rendering = false
	
	Global.export(captures)
	
	#
	#for i in captures.size():
		#var export_path = path + file_name + "-%s.png" % i
		#captures[i].save_png(export_path)
