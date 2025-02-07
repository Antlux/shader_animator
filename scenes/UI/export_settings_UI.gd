extends PanelContainer

@export var export_type_option_button: OptionButton
@export var export_button: Button


func _ready() -> void:
	var type_keys := ExportSettings.ExportType.keys() as Array
	var type_values := ExportSettings.ExportType.values() as Array
	for i in ExportSettings.ExportType.size():
		var type_name := type_keys[i] as String
		var type_value := type_values[i] as ExportSettings.ExportType
		export_type_option_button.add_item(type_name, type_value)
	
	export_type_option_button.select(export_type_option_button.get_item_index(Global.export_settings.export_type))
	

	export_type_option_button.item_selected.connect(_on_export_type_selected)
	Render.started_rendering.connect(_on_started_rendering)
	Render.ended_rendering.connect(_on_ended_rendering)



func _on_export_type_selected(idx: int) -> void:
	Global.export_settings.export_type = export_type_option_button.get_item_id(idx)

func _on_started_rendering() -> void:
	export_type_option_button.disabled = true
	export_button.disabled = true

func _on_ended_rendering() -> void:
	export_type_option_button.disabled = false
	export_button.disabled = false
