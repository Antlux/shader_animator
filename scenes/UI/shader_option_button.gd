extends OptionButton

const SHADER_FACES_PATH := "res://resources/custom/ShaderFace/shader_faces/"

@export var shader_animations : Array[ShaderAnimation] = []


func _ready() -> void:
	ShaderAnimationRenderer.started_rendering.connect(_on_started_rendering)
	ShaderAnimationRenderer.ended_rendering.connect(_on_ended_rendering)
	
	setup()
	item_selected.connect(_on_item_selected)
	select(0)
	select_shader(0)


func setup() -> void:
	for shader_animation in shader_animations:
		add_icon_item(shader_animation.get_texture(Vector2i(64, 64)), shader_animation.name)

func select_shader(idx: int) -> void:
	ShaderAnimationRenderer.shader_animation = shader_animations[idx]


func _on_item_selected(idx: int) -> void:
	select_shader(idx)

func _on_started_rendering() -> void:
	disabled = true

func _on_ended_rendering() -> void:
	disabled = false
