extends PanelContainer

@export var settings_container: Control

func _ready() -> void:
	Global.render_material_changed.connect(_on_render_material_changed)


func update_shader_settings_UI(render_material: ShaderMaterial) -> void:
	for c in settings_container.get_children():
		c.queue_free()
	
	for p: Dictionary in render_material.shader.get_shader_uniform_list():
		var p_name: String = p["name"]
		var p_type: Variant.Type = p["type"]
		var p_hint := (p["hint_string"] as String).split(",")
		#var p_usage: int = p["usage"]
		if ["outside_time"].has(p_name):
			continue
			
		match p_type:
			TYPE_BOOL:
				add_bool_parameter(render_material, p_name, p_hint)
			TYPE_INT:
				add_int_parameter(render_material, p_name, p_hint)
			TYPE_FLOAT:
				add_float_parameter(render_material, p_name, p_hint)
			TYPE_VECTOR2:
				add_vector2_parameter(render_material, p_name, p_hint)
			TYPE_VECTOR2I:
				add_vector2i_parameter(render_material, p_name, p_hint)
			TYPE_COLOR:
				add_color_parameter(render_material, p_name, p_hint)

func _on_render_material_changed(render_material: ShaderMaterial) -> void:
	update_shader_settings_UI(render_material)
 
func add_parameter_label(p_name: String) -> void:
	var p_label := Label.new()
	p_label.text = p_name
	settings_container.add_child(p_label)

func add_bool_parameter(render_material: ShaderMaterial, p_name: String, hint: PackedStringArray) -> void:
	add_parameter_label(p_name)
	
	var p_checkbox := CheckBox.new()
	p_checkbox.button_pressed = render_material.get_shader_parameter(p_name)
	p_checkbox.toggled.connect(func(toggle: bool): render_material.set_shader_parameter(p_name, toggle))
	settings_container.add_child(p_checkbox)

func add_int_parameter(render_material: ShaderMaterial, p_name: String, hint : PackedStringArray) -> void:
	add_parameter_label(p_name)
	
	var p_spinbox = SpinBox.new()
	
	if hint.size() > 1:
		p_spinbox.min_value = hint[0].to_float()
		p_spinbox.max_value = hint[1].to_float()
		p_spinbox.step = hint[2].to_float()
	else:
		p_spinbox.step = 1.0
		p_spinbox.min_value = -100
		p_spinbox.max_value = 100
	p_spinbox.value = render_material.get_shader_parameter(p_name)
	settings_container.add_child(p_spinbox)
	p_spinbox.value_changed.connect(func(value: int): 
		render_material.set_shader_parameter(p_name, value)
		)

func add_float_parameter(render_material: ShaderMaterial, p_name: String, hint : PackedStringArray) -> void:
	add_parameter_label(p_name)
	var p_spinbox = SpinBox.new()
	
	if hint.size() > 1:
		p_spinbox.min_value = hint[0].to_float()
		p_spinbox.max_value = hint[1].to_float()
		p_spinbox.step = hint[2].to_float()
	else:
		p_spinbox.step = 0.01
	p_spinbox.value = render_material.get_shader_parameter(p_name) if render_material.get_shader_parameter(p_name) != null else 0.0
	settings_container.add_child(p_spinbox)
	p_spinbox.value_changed.connect(func(value: float): 
		render_material.set_shader_parameter(p_name, value)
		)

func add_vector2_parameter(render_material: ShaderMaterial, p_name: String, hint : PackedStringArray) -> void:
	add_parameter_label(p_name)
	var p_x_spinbox := SpinBox.new()
	var p_y_spinbox := SpinBox.new()
	p_x_spinbox.value = render_material.get_shader_parameter(p_name).x if render_material.get_shader_parameter(p_name) != null else 0.0
	p_y_spinbox.value = render_material.get_shader_parameter(p_name).y if render_material.get_shader_parameter(p_name) != null else 0.0
	p_x_spinbox.step = 0.01
	p_y_spinbox.step = 0.01
	p_x_spinbox.prefix = "x:"
	p_y_spinbox.prefix = "y:"
	settings_container.add_child(p_x_spinbox)
	settings_container.add_child(Control.new())
	settings_container.add_child(p_y_spinbox)
	p_x_spinbox.value_changed.connect(func(value: float):
		var v = Vector2(value, render_material.get_shader_parameter(p_name).y if render_material.get_shader_parameter(p_name) != null else 0.0)
		render_material.set_shader_parameter(p_name, v)
		)
	p_y_spinbox.value_changed.connect(func(value: float): 
		var v = Vector2(render_material.get_shader_parameter(p_name).x if render_material.get_shader_parameter(p_name) != null else 0.0, value)
		render_material.set_shader_parameter(p_name, v)
		)

func add_vector2i_parameter(render_material: ShaderMaterial, p_name: String, hint : PackedStringArray) -> void:
	add_parameter_label(p_name)
	var p_x_spinbox := SpinBox.new()
	var p_y_spinbox := SpinBox.new()
	p_x_spinbox.value = render_material.get_shader_parameter(p_name).x if render_material.get_shader_parameter(p_name) != null else 0.0
	p_y_spinbox.value = render_material.get_shader_parameter(p_name).y if render_material.get_shader_parameter(p_name) != null else 0.0
	p_x_spinbox.step = 1.0
	p_y_spinbox.step = 1.0
	p_x_spinbox.prefix = "x:"
	p_y_spinbox.prefix = "y:"
	settings_container.add_child(p_x_spinbox)
	settings_container.add_child(Control.new())
	settings_container.add_child(p_y_spinbox)
	p_x_spinbox.value_changed.connect(func(value: float):
		var v = Vector2(value, render_material.get_shader_parameter(p_name).y if render_material.get_shader_parameter(p_name) != null else 0.0)
		render_material.set_shader_parameter(p_name, v)
		)
	p_y_spinbox.value_changed.connect(func(value: float): 
		var v = Vector2(render_material.get_shader_parameter(p_name).x if render_material.get_shader_parameter(p_name) != null else 0.0, value)
		render_material.set_shader_parameter(p_name, v)
		)

func add_color_parameter(render_material: ShaderMaterial, p_name: String, hint : PackedStringArray) -> void:
	add_parameter_label(p_name)
	var p_color_picker_button := ColorPickerButton.new()
	p_color_picker_button.color = render_material.get_shader_parameter(p_name) as Color
	p_color_picker_button.color_changed.connect(
		func(value): render_material.set_shader_parameter(p_name, value) 
			)
	p_color_picker_button.custom_minimum_size.y = 20.0
	settings_container.add_child(p_color_picker_button)
