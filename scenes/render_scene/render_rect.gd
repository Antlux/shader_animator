extends ColorRect

func _ready() -> void:
	Render.changed.connect(_on_render_material_changed)

func _on_render_material_changed(mat: ShaderMaterial) -> void:
	material = mat
