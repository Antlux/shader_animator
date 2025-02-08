extends ColorRect

func _ready() -> void:
	ShaderAnimationRenderer.shader_animation_changed.connect(_on_shader_animation_changed)


func update_shader_material(shader_animation: ShaderAnimation) -> void:
	if shader_animation:
		material = shader_animation.shader_material
	else:
		material = null


func _on_shader_animation_changed(shader_animation: ShaderAnimation) -> void:
	update_shader_material(shader_animation)
