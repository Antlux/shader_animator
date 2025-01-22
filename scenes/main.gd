extends Node

@export var sub_viewport: SubViewport
@export var render: ColorRect

@export var export_button : Button
@export var file_dialog: FileDialog


func _ready() -> void:
	#export_button.pressed.connect(_on_export_pressed)
	file_dialog.file_selected.connect(_on_file_selected)


func _on_export_pressed() -> void:
	file_dialog.current_dir = Global.export_settings.export_path.rsplit("/", false, 1)[0]
	file_dialog.show()

func _on_file_selected(file_path: String) -> void:
	var temp := file_path.rsplit("/", true, 1)
	var path := temp[0] + "/"
	var directory := temp[1]
	
	Global.export_settings.export_path = file_path
	
	var duration :=  Global.export_settings.duration
	var frame_count := Global.export_settings.frame_count
	
	var frame_delay := duration / (frame_count)
	
	var captures: Array[Image] = []
	
	Global.rendering = true
	
	for f in (frame_count):
		Global.render_material.set_shader_parameter("outside_time", frame_delay * f)
		await get_tree().process_frame
		await get_tree().process_frame
		captures.append(sub_viewport.get_texture().get_image())
	
	Global.rendering = false
	
	Global.export(captures)
	var tet = OK
