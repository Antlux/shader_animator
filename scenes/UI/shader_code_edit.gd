extends CodeEdit

@export var update_button: Button
var auto_update := true


func _ready() -> void:
	ShaderAnimationRenderer.shader_animation_changed.connect(_on_shader_animation_changed)
	ShaderAnimationRenderer.started_rendering.connect(_on_started_rendering)
	ShaderAnimationRenderer.ended_rendering.connect(_on_ended_rendering)
	#text_changed.connect(_on_text_changed)
	update_button.pressed.connect(_on_update_pressed)


func _on_shader_animation_changed(shader_animation: ShaderAnimation) -> void:
	if shader_animation:
		text = shader_animation.shader_material.shader.code
	else:
		text = ""

#func _on_text_changed() -> void:
	#if ShaderAnimationRenderer.shader_animation:
		#ShaderAnimationRenderer.shader_animation.shader_material.shader.code = text

func _on_update_pressed() -> void:
	if ShaderAnimationRenderer.shader_animation:
		ShaderAnimationRenderer.shader_animation.shader_material.shader.code = text
	ShaderAnimationRenderer.shader_animation_changed.emit(ShaderAnimationRenderer.shader_animation)

func _on_started_rendering() -> void:
	editable = false

func _on_ended_rendering() -> void:
	editable = true
