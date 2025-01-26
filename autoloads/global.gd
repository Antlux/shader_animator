extends Node

@onready var export_settings := ExportSettings.load_or_create()
@onready var render_settings := RenderSettings.load_or_create()

var current_time: float = 0.0

func _ready() -> void:
	export_settings.changed.connect(_on_export_settings_changed)
	render_settings.changed.connect(_on_render_settings_changed)
	apply_render_settings(Global.render_settings)

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
	var frame_delay := Global.render_settings.duration / Global.render_settings.frame_count
	
	var array : Array[PackedByteArray] = []
	for capture in captures:
		capture.convert(Image.FORMAT_RGBA8)
		array.append(capture.get_data())
	var width := Global.render_settings.resolution.x
	var height := Global.render_settings.resolution.y
	var path := Global.export_settings.export_path + ".webp"
	
	var error := AnimationExporter.export_webp(path, width, height, frame_delay, array) as Error
	assert(error == OK, "Webp export failed with code: %s" % error)

func export_gif(captures: Array[Image]) -> void:
	var frame_delay := Global.render_settings.duration / Global.render_settings.frame_count
	
	var array : Array[PackedByteArray] = []
	for capture in captures:
		capture.convert(Image.FORMAT_RGBA8)
		array.append(capture.get_data())
	var width := Global.render_settings.resolution.x
	var height := Global.render_settings.resolution.y
	var path := Global.export_settings.export_path + ".gif"
	
	var error := AnimationExporter.export_gif(path, width, height, frame_delay, array) as Error
	assert(error == OK, "GIF export failed with code: %s" % error)


func _on_export_settings_changed() -> void:
	export_settings.save()

func _on_render_settings_changed() -> void:
	render_settings.save()
	apply_render_settings(Global.render_settings)


func apply_render_settings(settings: RenderSettings) -> void:
	Render.size = settings.resolution
	Render.duration = settings.duration
	Render.frame_count = settings.frame_count
