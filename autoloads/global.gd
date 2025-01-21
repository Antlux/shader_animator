extends Node

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
			export_webp(captures)
		ExportSettings.ExportType.GIF:
			export_gif(captures)


#func export_gif(captures: Array[Image]) -> void:
	#var frame_delay := export_settings.duration / export_settings.frame_count
	#var exporter := GIFExporter.new(export_settings.resolution.x, export_settings.resolution.y)
	#
	#for capture in captures:
		#capture.convert(Image.FORMAT_RGBA8)
		#exporter.add_frame(capture, frame_delay, MedianCutQuantization)
	#
	#var file := FileAccess.open(export_settings.export_path + ".gif", FileAccess.WRITE)
	#file.store_buffer(exporter.export_file_data())
	#file.close()
	#

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
