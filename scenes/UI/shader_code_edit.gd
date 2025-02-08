extends CodeEdit

@export var update_button: Button
var auto_update := true


func _ready() -> void:
	setup()


func setup() -> void:
	ShaderAnimationRenderer.shader_animation_changed.connect(_on_shader_animation_changed)
	ShaderAnimationRenderer.started_rendering.connect(_on_started_rendering)
	ShaderAnimationRenderer.ended_rendering.connect(_on_ended_rendering)
	#text_changed.connect(_on_text_changed)
	update_button.pressed.connect(_on_update_pressed)

func update_shader_code(new_code: String) -> void:
	if ShaderAnimationRenderer.shader_animation:
		ShaderAnimationRenderer.shader_animation.shader_material.shader.code = new_code
	ShaderAnimationRenderer.shader_animation_changed.emit(ShaderAnimationRenderer.shader_animation)


func _on_shader_animation_changed(shader_animation: ShaderAnimation) -> void:
	text = shader_animation.shader_material.shader.code if shader_animation else ""

func _on_update_pressed() -> void:
	update_shader_code(text)

func _on_started_rendering() -> void:
	editable = false

func _on_ended_rendering() -> void:
	editable = true
