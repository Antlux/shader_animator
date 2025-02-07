extends ProgressBar

func _ready() -> void:
	Global.render_settings.changed.connect(_on_render_settings_changed)
	ShaderAnimationRenderer.updated.connect(_on_render_updated)
	self.max_value = Global.render_settings.frame_count - 1


func _on_render_settings_changed() -> void:
	self.max_value = Global.render_settings.frame_count - 1

func _on_render_updated(_timestamp: float, frame_idx: int) -> void:
	self.value = frame_idx
