extends ProgressBar

func _ready() -> void:
	Global.export_settings.changed.connect(_on_export_settings_changed)
	Global.render_material_updated.connect(_render_material_updated)
	self.max_value = Global.export_settings.duration


func _on_export_settings_changed() -> void:
	self.max_value = Global.export_settings.duration

func _render_material_updated(timestamp: float) -> void:
	self.value = timestamp
