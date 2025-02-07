extends Node
## Autoload that holds the active render shader material and parameters.

signal shader_animation_changed(shader_animation: ShaderAnimation) ## Emited when the active render shader material is changed.
signal updated(timestamp: float, current_frame: int) ## Emited when the active render is updated.
signal resized(from: Vector2i, to: Vector2i) ## Emited when the active render is resized.

signal started_rendering
signal ended_rendering

var render_viewport: SubViewport = null

## Active render shader material
var shader_animation: ShaderAnimation

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
	if shader_animation == null:
		return
		
	if shader_animation.shader_material == null:
		return
	
	if not _rendering:
		set_time(current_time + delta)


func change_shader_animation(to: ShaderAnimation) -> void:
	if shader_animation and shader_animation.shader_parameter_changed.is_connected(_on_shader_parameter_changed):
		shader_animation.shader_parameter_changed.disconnect(_on_shader_parameter_changed)
		
	shader_animation = to
	shader_animation.shader_parameter_changed.connect(_on_shader_parameter_changed)
	
	shader_animation_changed.emit(shader_animation)


## Set the active render shader material time to the [param timestamp] parameter (in seconds) and emits [signal Render.updated].
func set_time(timestamp: float) -> void:
	current_time = fmod(timestamp, duration)
	current_frame = floori(current_time / duration * frame_count)
	var frame_rate = frame_count / duration;
	var timestamp_floored = floor(current_time * frame_rate) /  frame_rate
	shader_animation.shader_material.set_shader_parameter("outside_time", timestamp_floored)
	updated.emit(timestamp_floored, current_frame)

## Set the active render shader material frame index to the [param index] parameter (in seconds) and emits [signal Render.updated].
func set_frame(index: int) -> void:
	current_frame = index % frame_count
	var frame_rate = frame_count / duration;
	current_time = index * frame_rate
	shader_animation.shader_material.set_shader_parameter("outside_time", current_time)
	updated.emit(current_time, current_frame)


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


func _on_shader_parameter_changed() -> void:
	shader_animation.save()
