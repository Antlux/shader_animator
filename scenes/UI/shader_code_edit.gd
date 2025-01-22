extends CodeEdit


func _ready() -> void:
	Global.render_material_changed.connect(_on_render_material_changed)
	text_changed.connect(_on_text_changed)


func _on_render_material_changed(render_material: ShaderMaterial) -> void:
	text = render_material.shader.code

func _on_text_changed() -> void:
	Global.render_material.shader.code = text
