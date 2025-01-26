extends SubViewport

func _ready() -> void:
	Render.resized.connect(_on_render_resized)
	size = Render.size

func update_size(new_size: Vector2i) -> void:
	size = new_size

func _on_render_resized(new_size: Vector2i) -> void:
	update_size(new_size)
