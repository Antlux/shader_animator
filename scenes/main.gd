extends Node

@export var render_viewport: SubViewport

@export var export_button : Button
@export var file_dialog: FileDialog


func _ready() -> void:
	export_button.pressed.connect(_on_export_pressed)
	file_dialog.dir_selected.connect(_on_dir_selected)
	file_dialog.add_option("Export type", ExportSettings.ExportType.keys(), Global.export_settings.export_type)


func _on_export_pressed() -> void:
	file_dialog.current_dir = Global.export_settings.export_path.rsplit("/", false, 1)[0]
	file_dialog.show()

func _on_dir_selected(dir_path: String) -> void:

	Global.export_settings.export_path = dir_path + "/"
	var test = file_dialog.get_selected_options()["Export type"] as ExportSettings.ExportType
	print(test)
	Global.export_settings.export_type = test
	
	var duration :=  Global.render_settings.duration
	var frame_count := Global.render_settings.frame_count
	
	var frame_delay := duration / (frame_count)
	
	var captures: Array[Image] = []
	
	Global.rendering = true
	
	for f in (frame_count):
		Global.render_material.set_shader_parameter("outside_time", frame_delay * f)
		await get_tree().process_frame
		await get_tree().process_frame
		captures.append(render_viewport.get_texture().get_image())
	
	Global.rendering = false
	
	Global.export(captures)
