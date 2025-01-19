extends Node

const GIFExporter = preload("res://addons/gdgifexporter/exporter.gd")
const MedianCutQuantization = preload("res://addons/gdgifexporter/quantization/median_cut.gd")

@onready var export_settings := ExportSettings.load_or_create()


func _ready() -> void:
	export_settings.changed.connect(_on_export_settings_changed)

func _on_export_settings_changed() -> void:
	export_settings.save()


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
			for idx in captures.size():
				var capture := captures[idx]
				var error := capture.save_webp(Global.export_settings.export_path + "-%s.webp" % idx)
				assert(error == OK, "Could not save as webp")
		ExportSettings.ExportType.GIF:
			export_gif(captures)


func export_gif(captures: Array[Image]) -> void:
	var frame_delay := export_settings.duration / export_settings.frame_count
	var exporter := GIFExporter.new(export_settings.resolution.x, export_settings.resolution.y)
	
	for capture in captures:
		capture.convert(Image.FORMAT_RGBA8)
		exporter.add_frame(capture, frame_delay, MedianCutQuantization)
	
	var file := FileAccess.open(export_settings.export_path + ".gif", FileAccess.WRITE)
	file.store_buffer(exporter.export_file_data())
	file.close()
