class_name ShaderAnimation extends Resource

signal shader_parameter_changed

@export var shader_material: ShaderMaterial
@export var name: String = "Shader"
@export var parameters_dict: Dictionary

var sub_viewport: SubViewport = null


## Returns an array of [Render.Parameter] that hold the parameters of the active render shader material.
func get_parameters() -> Array[Parameter]:
	var parameters: Array[Parameter] = []
	
	for param_dict: Dictionary in shader_material.shader.get_shader_uniform_list():
		
		var p_name: String = param_dict["name"]
		var p_type: Variant.Type = param_dict["type"]
		var p_hint := (param_dict["hint_string"] as String).split(",")
		
		if ["outside_time"].has(p_name):
			continue
		
		parameters.append(Parameter.new(self, p_name, p_type, p_hint))
	
	return parameters

func get_texture(texture_size: Vector2i) -> ViewportTexture:
	if not sub_viewport:
		sub_viewport = SubViewport.new()
		var texture_rect := ColorRect.new()
		sub_viewport.size = texture_size
		texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		texture_rect.material = shader_material
		sub_viewport.add_child(texture_rect)
		Global.get_tree().root.add_child.call_deferred(sub_viewport)
	
	return sub_viewport.get_texture()


func generate_parameters_dict() -> Dictionary:
	var param_dict := {}
	for param in get_parameters():
		param_dict[param.name] = param.get_value()
	return param_dict

func apply_parameters_dict() -> void:
	for idx in parameters_dict.size():
		var param_name : String = parameters_dict.keys()[idx]
		var param_value : Variant = parameters_dict.values()[idx]
		shader_material.set_shader_parameter(param_name, param_value)



## Class that points to a specific parameter of an animation.
class Parameter:
	var shader_animation: ShaderAnimation
	var name: String ## Name of the parameter.
	var type: Variant.Type ## Held value type.
	var hint: PackedStringArray ## Hint.
	
	func _init(_shader_animation: ShaderAnimation, _name: String, _type: Variant.Type, _hint := PackedStringArray()) -> void:
		shader_animation = _shader_animation
		name = _name
		type = _type
		hint = _hint
	
	## Sets the pointed parameter of the active render material to [param value].
	func set_value(value: Variant) -> void:
		shader_animation.shader_material.set_shader_parameter(name, value)
		shader_animation.shader_parameter_changed.emit()
	
	## Returns the value of pointed parameter of the active render material.
	func get_value() -> Variant:
		return shader_animation.shader_material.get_shader_parameter(name)
	
