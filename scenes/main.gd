extends Node

@export var export_render_button : Button
@export var export_render_file_dialog: FileDialog


func _ready() -> void:
	export_render_button.pressed.connect(_on_export_render_pressed)
	export_render_file_dialog.file_selected.connect(_on_export_render_file_selected)


func setup_file_dialog() -> void:
	var extension :=  ExportSettings.get_extension(Global.export_settings.export_type)
	export_render_file_dialog.current_path = Global.export_settings.export_path.rsplit("/", true, 1)[0] + "/"
	export_render_file_dialog.clear_filters()
	export_render_file_dialog.add_filter("*." + extension, "animation")


func _on_export_render_pressed() -> void:
	if OS.has_feature("web"):
		Global.export_web(await ShaderAnimationRenderer.render_frames())
		return
	
	setup_file_dialog()
	export_render_file_dialog.popup()

func _on_export_render_file_selected(path: String) -> void:
	Global.export_settings.export_path = path
	Global.export(await ShaderAnimationRenderer.render_frames())
