extends Node

signal changed(render_material: ShaderMaterial)
signal updated(timestamp: float)
signal resized(new_size: Vector2i)

var render_material : ShaderMaterial:
	set(value):
		if render_material != value:
			render_material = value
			changed.emit(value)
var rendering := false
var current_time: float = 0.0

var size := Vector2i(512, 512) :
	set(value):
		if size != value:
			size = value
			resized.emit(value)
var duration: float = 1.0
var frame_count: int = 1

func update(timestamp: float) -> void:
	render_material.set_shader_parameter("outside_time", timestamp)
	updated.emit(timestamp)

func _process(delta: float) -> void:
	
	if render_material == null:
		return
	
	if not rendering:
		current_time = fmod(current_time + delta, duration)
		var frame_rate = frame_count / duration;
		var timestamp = floor(current_time * frame_rate) /  frame_rate
		update(timestamp)
