extends SubViewport

func _ready() -> void:
	setup()


func setup() -> void:
	ShaderAnimationRenderer.render_viewport = self
	ShaderAnimationRenderer.resized.connect(_on_render_resized)
	update_size(ShaderAnimationRenderer.size)

func update_size(new_size: Vector2i) -> void:
	size = new_size


func _on_render_resized(_from: Vector2i, to: Vector2i) -> void:
	update_size(to)
