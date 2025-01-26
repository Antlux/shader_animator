extends ProgressBar

func _ready() -> void:
	Global.render_settings.changed.connect(_on_render_settings_changed)
	Render.updated.connect(_on_render_updated)
	self.max_value = Global.render_settings.duration


func _on_render_settings_changed() -> void:
	self.max_value = Global.render_settings.duration

func _on_render_updated(timestamp: float) -> void:
	self.value = timestamp
