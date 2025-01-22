extends PanelContainer

@export var export_type_option_button: OptionButton


func _ready() -> void:
	var type_keys := ExportSettings.ExportType.keys() as Array
	var type_values := ExportSettings.ExportType.values() as Array
	for i in ExportSettings.ExportType.size():
		var type_name := type_keys[i] as String
		var type_value := type_values[i] as ExportSettings.ExportType
		export_type_option_button.add_item(type_name, type_value)
	
	export_type_option_button.select(export_type_option_button.get_item_index(Global.export_settings.export_type))
	

	export_type_option_button.item_selected.connect(_on_export_type_selected)




func _on_export_type_selected(idx: int) -> void:
	Global.export_settings.export_type = export_type_option_button.get_item_id(idx)
