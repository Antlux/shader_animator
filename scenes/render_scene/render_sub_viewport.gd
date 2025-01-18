extends SubViewport

func _ready() -> void:
	update_render_resolution()
	Global.export_settings.changed.connect(_on_export_settings_changed)

func update_render_resolution() -> void:
	size = Global.export_settings.resolution

func _on_export_settings_changed() -> void:
	update_render_resolution()
