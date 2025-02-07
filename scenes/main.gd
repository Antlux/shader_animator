extends Node

@export var export_button : Button
@export var file_dialog: FileDialog



func _ready() -> void:
	export_button.pressed.connect(_on_export_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	


func _on_export_pressed() -> void:
	file_dialog.current_dir = Global.export_settings.export_path
	
	if OS.has_feature("web"):
		Global.export_web(await ShaderAnimationRenderer.render_frames())
		return
	
	var extension := (ExportSettings.ExportType.keys()[Global.export_settings.export_type] as String).to_lower()
	file_dialog.clear_filters()
	file_dialog.add_filter("*." + extension, "animation")
	file_dialog.show()



func _on_file_selected(dir_path: String) -> void:

	Global.export_settings.export_path = dir_path
	

	Global.export(await ShaderAnimationRenderer.render_frames())
