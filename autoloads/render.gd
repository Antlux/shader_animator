extends Node

signal changed(render_material: ShaderMaterial)
signal parameter_changed
signal updated(timestamp: float, current_frame: int)
signal resized(from: Vector2i, to: Vector2i)

var render_material : ShaderMaterial:
	set(value):
		if render_material != value:
			render_material = value
			changed.emit(value)
var rendering := false
var current_time: float = 0.0
var current_frame: int = 0

var size := Vector2i(512, 512) :
	set(value):
		if size != value:
			var previous := size
			size = value
			resized.emit(previous, value)

var duration: float = 1.0
var frame_count: int = 1


func _process(delta: float) -> void:
	
	if render_material == null:
		return
	
	if not rendering:
		current_time = fmod(current_time + delta, duration)
		current_frame = floori(current_time / duration * frame_count)
		var frame_rate = frame_count / duration;
		var timestamp = floor(current_time * frame_rate) /  frame_rate
		update(timestamp)


func update(timestamp: float) -> void:
	render_material.set_shader_parameter("outside_time", timestamp)
	updated.emit(timestamp, current_frame)

func get_parameters() -> Array[Parameter]:
	var parameters: Array[Parameter] = []
	
	for param_dict: Dictionary in Render.render_material.shader.get_shader_uniform_list():
		
		var p_name: String = param_dict["name"]
		var p_type: Variant.Type = param_dict["type"]
		var p_hint := (param_dict["hint_string"] as String).split(",")
		
		if ["outside_time"].has(p_name):
			continue
		
		parameters.append(Parameter.new(p_name, p_type, p_hint))
	
	return parameters

class Parameter:
	var name: String
	var type: Variant.Type
	var hint: PackedStringArray
	
	func _init(_name: String, _type: Variant.Type, _hint := PackedStringArray()) -> void:
		name = _name
		type = _type
		hint = _hint
	
	func set_value(value: Variant) -> void:
		Render.render_material.set_shader_parameter(name, value)
		Render.parameter_changed.emit()
	
	func get_value() -> Variant:
		return Render.render_material.get_shader_parameter(name)
	
