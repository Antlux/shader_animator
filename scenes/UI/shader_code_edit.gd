extends CodeEdit

var auto_update := true


func _ready() -> void:
	Render.changed.connect(_on_render_changed)
	Render.started_rendering.connect(_on_started_rendering)
	Render.ended_rendering.connect(_on_ended_rendering)
	text_changed.connect(_on_text_changed)


func _on_render_changed(render_material: ShaderMaterial) -> void:
	text = render_material.shader.code

func _on_text_changed() -> void:
	Render.render_material.shader.code = text

func _on_started_rendering() -> void:
	editable = false

func _on_ended_rendering() -> void:
	editable = true
