extends Node
## Autoload that holds the active render shader material and parameters.

signal changed(render_material: ShaderMaterial) ## Emited when the active render shader material is changed.
signal parameter_changed ## Emited when a parameter of the active render material is changed.
signal updated(timestamp: float, current_frame: int) ## Emited when the active render is updated.
signal resized(from: Vector2i, to: Vector2i) ## Emited when the active render is resized.

signal started_rendering
signal ended_rendering

var render_viewport: SubViewport = null

## Active render shader material
var render_material : ShaderMaterial: 
	set(value):
		if render_material != value:
			render_material = value
			changed.emit(value)


var _rendering := false 


## Duration of the animation loop in seconds.
var duration: float = 1.0 

## Frame count of the animation loop.
var frame_count: int = 1

## Current position (in seconds) in the animation loop.
var current_time: float = 0.0

## Current frame index in the animation loop.
var current_frame: int = 0

## Size of the active render 
var size := Vector2i(512, 512) :
	set(value):
		if size != value:
			var previous := size
			size = value
			resized.emit(previous, value)



func _process(delta: float) -> void:
	
	if render_material == null:
		return
	
	if not _rendering:
		set_time(current_time + delta)


## Set the active render shader material time to the [param timestamp] parameter (in seconds) and emits [signal Render.updated].
func set_time(timestamp: float) -> void:
	current_time = fmod(timestamp, duration)
	current_frame = floori(current_time / duration * frame_count)
	var frame_rate = frame_count / duration;
	var timestamp_floored = floor(current_time * frame_rate) /  frame_rate
	render_material.set_shader_parameter("outside_time", timestamp_floored)
	updated.emit(timestamp_floored, current_frame)

## Set the active render shader material frame index to the [param index] parameter (in seconds) and emits [signal Render.updated].
func set_frame(index: int) -> void:
	current_frame = index % frame_count
	var frame_rate = frame_count / duration;
	current_time = index * frame_rate
	render_material.set_shader_parameter("outside_time", current_time)
	updated.emit(current_time, current_frame)

## Returns an array of [Render.Parameter] that hold the parameters of the active render shader material.
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

func render_frames() -> Array[Image]:
	var captures: Array[Image] = []
	
	_rendering = true
	started_rendering.emit()
	
	for f in frame_count:
		set_frame(f)
		await get_tree().process_frame
		await get_tree().process_frame
		captures.append(render_viewport.get_texture().get_image())
	
	_rendering = false
	ended_rendering.emit()
	
	return captures

## Class that points to a specific parameter of the active render material.
class Parameter:
	var name: String ## Name of the parameter.
	var type: Variant.Type ## Held value type.
	var hint: PackedStringArray ## Hint.
	
	func _init(_name: String, _type: Variant.Type, _hint := PackedStringArray()) -> void:
		name = _name
		type = _type
		hint = _hint
	
	## Sets the pointed parameter of the active render material to [param value].
	func set_value(value: Variant) -> void:
		Render.render_material.set_shader_parameter(name, value)
		Render.parameter_changed.emit()
	
	## Returns the value of pointed parameter of the active render material.
	func get_value() -> Variant:
		return Render.render_material.get_shader_parameter(name)
	
