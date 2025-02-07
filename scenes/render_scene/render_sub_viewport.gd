extends SubViewport

func _ready() -> void:
	Render.render_viewport = self
	Render.resized.connect(_on_render_resized)
	size = Render.size

func update_size(new_size: Vector2i) -> void:
	size = new_size

func _on_render_resized(from: Vector2i, to: Vector2i) -> void:
	update_size(to)
