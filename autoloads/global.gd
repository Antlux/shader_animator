extends Node

signal render_material_changed(mat: ShaderMaterial)

@onready var export_settings := ExportSettings.load_or_create()

var current_time: float = 0.0
var rendering := false
var render_material: ShaderMaterial:
	set(value):
		render_material = value
		render_material_changed.emit(value)


func _ready() -> void:
	export_settings.changed.connect(_on_export_settings_changed)


func _process(delta: float) -> void:
	
	if render_material == null:
		return
	
	var duration := Global.export_settings.duration
	var frame_count := Global.export_settings.frame_count
	
	if not rendering:
		current_time = fmod(current_time + delta, duration)
		var frame_rate = frame_count / duration;
		var value = floor(current_time * frame_rate) /  frame_rate
		render_material.set_shader_parameter("outside_time", value)


func export(captures: Array[Image]) -> void:
	match export_settings.export_type:
		ExportSettings.ExportType.EXR:
			for idx in captures.size():
				var capture := captures[idx]
				var error := capture.save_exr(Global.export_settings.export_path + "-%s.exr" % idx)
				assert(error == OK, "Could not save as exr")
		ExportSettings.ExportType.JPG:
			for idx in captures.size():
				var capture := captures[idx]
				var error := capture.save_jpg(Global.export_settings.export_path + "-%s.jpg" % idx)
				assert(error == OK, "Could not save as jpg")
		ExportSettings.ExportType.PNG:
			for idx in captures.size():
				var capture := captures[idx]
				var error := capture.save_png(Global.export_settings.export_path + "-%s.png" % idx)
				assert(error == OK, "Could not save as png")
		ExportSettings.ExportType.WEBP:
			export_webp(captures)
		ExportSettings.ExportType.GIF:
			export_gif(captures)

func export_webp(captures: Array[Image]) -> void:
	var frame_delay := export_settings.duration / export_settings.frame_count
	
	var array : Array[PackedByteArray] = []
	for capture in captures:
		capture.convert(Image.FORMAT_RGBA8)
		array.append(capture.get_data())
	var width := export_settings.resolution.x
	var height := export_settings.resolution.y
	var path := export_settings.export_path + ".webp"
	
	AnimationExporter.export_webp(path, width, height, frame_delay, array)

func export_gif(captures: Array[Image]) -> void:
	var frame_delay := export_settings.duration / export_settings.frame_count
	
	var array : Array[PackedByteArray] = []
	for capture in captures:
		capture.convert(Image.FORMAT_RGBA8)
		array.append(capture.get_data())
	var width := export_settings.resolution.x
	var height := export_settings.resolution.y
	var path := export_settings.export_path + ".gif"
	
	AnimationExporter.export_gif(path, width, height, frame_delay, array)


func _on_export_settings_changed() -> void:
	export_settings.save()
