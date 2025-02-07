extends CodeEdit

var auto_update := true


func _ready() -> void:
	ShaderAnimationRenderer.shader_animation_changed.connect(_on_shader_animation_changed)
	ShaderAnimationRenderer.started_rendering.connect(_on_started_rendering)
	ShaderAnimationRenderer.ended_rendering.connect(_on_ended_rendering)
	text_changed.connect(_on_text_changed)


func _on_shader_animation_changed(shader_animation: ShaderAnimation) -> void:
	if shader_animation:
		text = shader_animation.shader_material.shader.code
	else:
		text = ""

func _on_text_changed() -> void:
	if ShaderAnimationRenderer.shader_animation:
		ShaderAnimationRenderer.shader_animation.shader_material.shader.code = text

func _on_started_rendering() -> void:
	editable = false

func _on_ended_rendering() -> void:
	editable = true
