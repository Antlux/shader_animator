extends CodeEdit

var auto_update := true


func _ready() -> void:
	Render.changed.connect(_on_render_changed)
	text_changed.connect(_on_text_changed)


func _on_render_changed(render_material: ShaderMaterial) -> void:
	text = render_material.shader.code

func _on_text_changed() -> void:
	Render.render_material.shader.code = text
