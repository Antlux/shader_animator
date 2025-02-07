extends PanelContainer

@export var settings_container: Control


func _ready() -> void:
	ShaderAnimationRenderer.shader_animation_changed.connect(_on_shader_animation_changed)
	ShaderAnimationRenderer.started_rendering.connect(_on_started_rendering)
	ShaderAnimationRenderer.ended_rendering.connect(_on_ended_rendering)
	
	if ShaderAnimationRenderer.shader_animation:
		update_shader_settings_UI()


func update_shader_settings_UI() -> void:
	for c in settings_container.get_children():
		c.queue_free()
	
	for parameter in ShaderAnimationRenderer.shader_animation.get_parameters():
		
		match parameter.type:
			TYPE_BOOL:
				add_bool_parameter(parameter)
			TYPE_INT:
				add_int_parameter(parameter)
			TYPE_FLOAT:
				add_float_parameter(parameter)
			TYPE_VECTOR2:
				add_vector2_parameter(parameter)
			TYPE_VECTOR2I:
				add_vector2i_parameter(parameter)
			TYPE_COLOR:
				add_color_parameter(parameter)
			#TYPE_OBJECT:
				#match p_hint[0]:
					#"Texture2D":
						#add_texture_parameter(render_material, p_name)

func add_parameter_label(p_name: String) -> void:
	var p_label := Label.new()
	p_label.text = p_name
	settings_container.add_child(p_label)

func add_spinbox(value_changed_function: Callable, value: float, settings: SpinboxSettings = null) -> void:
	var spinbox := SpinBox.new()
	
	if settings:
		spinbox.min_value = settings.min
		spinbox.max_value = settings.max
		spinbox.step = settings.step
		spinbox.prefix = settings.prefix
		spinbox.suffix = settings.suffix
	else:
		spinbox.min_value = -100
		spinbox.max_value = 100
		spinbox.step = 1.0
		spinbox.prefix = ""
		spinbox.suffix = ""
		
	spinbox.value_changed.connect(value_changed_function)
	
	settings_container.add_child(spinbox)
	
	spinbox.set_value_no_signal(value)

func add_bool_parameter(parameter: ShaderAnimation.Parameter) -> void:
	add_parameter_label(parameter.name)
	var parameter_checkbox := CheckBox.new()
	parameter_checkbox.button_pressed = parameter.get_value()
	parameter_checkbox.toggled.connect(func(toggle: bool): parameter.set_value(toggle))

func add_int_parameter(parameter: ShaderAnimation.Parameter) -> void:
	add_parameter_label(parameter.name)
	
	var spinbox_settings : SpinboxSettings = null
	if parameter.hint.size() > 1:
		spinbox_settings = SpinboxSettings.new(
			parameter.hint[0].to_float(), 
			parameter.hint[1].to_float(), 
			parameter.hint[2].to_float()
		)
	var start_value : int = parameter.get_value()
	var value_changed_function := func(value: int): 
		parameter.set_value(value)
	
	add_spinbox(value_changed_function, start_value, spinbox_settings)

func add_float_parameter(parameter: ShaderAnimation.Parameter) -> void:
	add_parameter_label(parameter.name)
	
	var spinbox_settings := SpinboxSettings.new(-100, 100, 0.01) 
	if parameter.hint.size() > 1:
			spinbox_settings = SpinboxSettings.new(
				parameter.hint[0].to_float(), 
				parameter.hint[1].to_float(), 
				parameter.hint[2].to_float()
			)
	
	var start_value : float = parameter.get_value()
	var value_changed_function := func(value: float): parameter.set_value(value)
	add_spinbox(value_changed_function, start_value, spinbox_settings)

func add_vector2_parameter(parameter: ShaderAnimation.Parameter) -> void:
	add_parameter_label(parameter.name)
	
	var x_spinbox_settings := SpinboxSettings.new(-16384, 16384, .01, "x:")
	var x_start_value: float = (parameter.get_value() as Vector2).x
	var x_value_changed_function := func(value: float):
		var new_value = Vector2(value, (parameter.get_value() as Vector2).y)
		parameter.set_value(new_value)
	add_spinbox(x_value_changed_function, x_start_value, x_spinbox_settings)
	
	
	settings_container.add_child(Control.new())
	
	var y_spinbox_settings := SpinboxSettings.new(-16384, 16384, .01, "y:")
	var y_start_value: float = (parameter.get_value() as Vector2).y
	var y_value_changed_function := func(value: float): 
		var new_value = Vector2((parameter.get_value() as Vector2).x, value)
		parameter.set_value(new_value)
	add_spinbox(y_value_changed_function, y_start_value, y_spinbox_settings)

func add_vector2i_parameter(parameter: ShaderAnimation.Parameter) -> void:
	add_parameter_label(parameter.name)
	
	var x_spinbox_settings := SpinboxSettings.new(-16384, 16384, 1.0, "x:")
	var x_start_value: int = (parameter.get_value() as Vector2i).x
	var x_value_changed_function := func(value: int):
		var new_value = Vector2i(value, (parameter.get_value() as Vector2i).y)
		parameter.set_value(new_value)
	add_spinbox(x_value_changed_function, x_start_value, x_spinbox_settings)

	
	settings_container.add_child(Control.new())
	
	var y_spinbox_settings := SpinboxSettings.new(-16384, 16384, 1.0, "y:")
	var y_start_value: int = (parameter.get_value() as Vector2i).y
	var y_value_changed_function := func(value: int): 
		var new_value = Vector2((parameter.get_value() as Vector2i).x, value)
		parameter.set_value(new_value)
	add_spinbox(y_value_changed_function, y_start_value, y_spinbox_settings)


func add_color_parameter(parameter: ShaderAnimation.Parameter) -> void:
	add_parameter_label(parameter.name)
	var p_color_picker_button := ColorPickerButton.new()
	p_color_picker_button.color = parameter.get_value() as Color
	p_color_picker_button.color_changed.connect(func(value): parameter.set_value(value))
	p_color_picker_button.custom_minimum_size.y = 20.0
	settings_container.add_child(p_color_picker_button)

func add_texture_parameter(render_material: ShaderMaterial, p_name: String) -> void:
	add_parameter_label(p_name)
	var p_texture_button := TextureButton.new()
	p_texture_button.ignore_texture_size = true
	p_texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	p_texture_button.texture_normal = render_material.get_shader_parameter(p_name)
	p_texture_button.custom_minimum_size.y = 64.0
	settings_container.add_child(p_texture_button)
	
	var texture_file_dialog := FileDialog.new()
	texture_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	texture_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE


func _on_shader_animation_changed(_shader_animation: ShaderAnimation) -> void:
	update_shader_settings_UI()

func _on_started_rendering() -> void:
	for child in settings_container.get_children():
		if child.get("disabled") != null:
			child.disabled = true
		if child.get("editable") != null:
			child.editable = false

func _on_ended_rendering() -> void:
	for child in settings_container.get_children():
		if child.get("disabled") != null:
			child.disabled = false
		if child.get("editable") != null:
			child.editable = true

class SpinboxSettings:
	var step: float
	var min: float
	var max: float
	var prefix: String
	var suffix: String
	
	func _init( _min: float, _max: float, _step: float, _prefix: String = "", _suffix: String = "") -> void:
		min = _min
		max = _max
		step = _step
		prefix = _prefix
		suffix = _suffix
