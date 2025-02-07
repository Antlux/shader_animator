extends Node

@export var render_viewport: SubViewport

@export var export_button : Button
@export var file_dialog: FileDialog



func _ready() -> void:
	export_button.pressed.connect(_on_export_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	


func _on_export_pressed() -> void:
	var extension := (ExportSettings.ExportType.keys()[Global.export_settings.export_type] as String).to_lower()
	file_dialog.current_dir = Global.export_settings.export_path.rsplit("/", true, 1)[0]
	
	if OS.has_feature("web"):
		Global.export_web(await get_captures())
		return
	
	file_dialog.clear_filters()
	file_dialog.add_filter("*." + extension, "animation")
	file_dialog.show()


func get_captures() -> Array[Image]:
	var duration :=  Global.render_settings.duration
	var frame_count := Global.render_settings.frame_count
	
	var frame_delay := duration / (frame_count)
	
	var captures: Array[Image] = []
	
	Render.rendering = true
	
	for f in (frame_count):
		Render.update(frame_delay * f)
		await get_tree().process_frame
		await get_tree().process_frame
		captures.append(render_viewport.get_texture().get_image())
	
	Render.rendering = false
	
	return captures


func _on_file_selected(dir_path: String) -> void:

	Global.export_settings.export_path = dir_path
	

	Global.export(await get_captures())
