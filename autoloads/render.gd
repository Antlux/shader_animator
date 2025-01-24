extends Node

signal changed
signal updated(timestamp: float)
signal resized

var render_material : ShaderMaterial:
	set(value):
		if render_material != value:
			render_material = value
			changed.emit()

var size := Vector2i(512, 512) :
	set(value):
		if size != value:
			size = value
			resized.emit()


func update(timestamp: float) -> void:
	render_material.set_shader_parameter("outside_time", timestamp)
	updated.emit(timestamp)
