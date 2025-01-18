extends Node

@onready var export_settings := ExportSettings.load_or_create()


func _ready() -> void:
	export_settings.changed.connect(_on_export_settings_changed)

func _on_export_settings_changed() -> void:
	export_settings.save()
