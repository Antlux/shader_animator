extends Node

signal shader_animation_list_updated

const FONT_DRIP: ShaderAnimation = preload("res://resources/custom/ShaderAnimation/shader_animations/font_drip.tres")
const FONT_FLOW: ShaderAnimation = preload("res://resources/custom/ShaderAnimation/shader_animations/font_flow.tres")
const FONT_SPIRAL: ShaderAnimation = preload("res://resources/custom/ShaderAnimation/shader_animations/font_spiral.tres")

@onready var export_settings := ExportSettings.load_or_create()
@onready var render_settings := RenderSettings.load_or_create()

var shader_animation_list: Array[ShaderAnimation] = []
var current_time: float = 0.0

func _ready() -> void:
	export_settings.changed.connect(_on_export_settings_changed)
	render_settings.changed.connect(_on_render_settings_changed)
	
	shader_animation_list = load_shader_animations()
	shader_animation_list_updated.emit()
	
	if shader_animation_list.is_empty():
		reset_shader_animations()
	
	apply_render_settings(Global.render_settings)


func load_shader_animations() -> Array[ShaderAnimation]:
	var arr: Array[ShaderAnimation] = []
	var shader_animations_dir := DirAccess.open("user://shader_animations/")
	if not shader_animations_dir:
		return arr
		
	for path in shader_animations_dir.get_files():
		var anim := ShaderAnimation.load_animation("user://shader_animations/" + path)
		if anim:
			arr.append(anim)
	
	return arr

func add_shader_animation(animation_name: String) -> void:
	if not animation_name.is_empty():
		var new_animation := ShaderAnimation.create(animation_name)
		shader_animation_list.append(new_animation)
		shader_animation_list_updated.emit()

func remove_shader_animation(shader_animation: ShaderAnimation) -> void:
	shader_animation.remove_from_system()
	shader_animation_list.erase(shader_animation)
	shader_animation_list_updated.emit()

func reset_shader_animations() -> void:
	var list: Array[ShaderAnimation] = [
		FONT_DRIP, 
		FONT_FLOW, 
		FONT_SPIRAL
	]
	
	for shader_animation in list:
		shader_animation.save()
	
	shader_animation_list = load_shader_animations()
	
	shader_animation_list_updated.emit()

func apply_render_settings(settings: RenderSettings) -> void:
	ShaderAnimationRenderer.size = settings.resolution
	ShaderAnimationRenderer.duration = settings.duration
	ShaderAnimationRenderer.frame_count = settings.frame_count


func export(captures: Array[Image]) -> void:
	var split_path := Global.export_settings.export_path.rsplit(".", true, 1) as PackedStringArray
	var stem := split_path[0]
	var extension := split_path[1]
	
	match export_settings.export_type:
		#ExportSettings.ExportType.WEBP:
			#export_webp(captures)
		#ExportSettings.ExportType.GIF:
			#export_gif(captures)
		ExportSettings.ExportType.EXR: 
			for idx in captures.size():
				var capture := captures[idx]
				var path := stem + ("-%s." % idx) + extension
				var error : Error = capture.save_exr(path)
				assert(error == OK, "Could not save as %s" % extension)
		ExportSettings.ExportType.JPG:
			for idx in captures.size():
				var capture := captures[idx]
				var path := stem + ("-%s." % idx) + extension
				var error : Error = capture.save_jpg(path)
				assert(error == OK, "Could not save as %s" % extension)
		ExportSettings.ExportType.PNG:
			for idx in captures.size():
				var capture := captures[idx]
				var path := stem + ("-%s." % idx) + extension
				var error : Error = capture.save_png(path)
				assert(error == OK, "Could not save as %s" % extension)
	

	

			
			
		#ExportSettings.ExportType.JPG:
			#var split_path := Global.export_settings.export_path.rsplit(".", true, 1)
			#var extension := split_path[0]
			#var stem := split_path[1]
			#for idx in captures.size():
				#var capture := captures[idx]
				#var path := stem + ("-%s." % idx) + extension
				#var error := capture.save_jpg(path)
				#assert(error == OK, "Could not save as jpg")
		#ExportSettings.ExportType.PNG:
			#for idx in captures.size():
				#var capture := captures[idx]
				#var error := capture.save_png(Global.export_settings.export_path + "-%s.png" % idx)
				#assert(error == OK, "Could not save as png")
		#
		#_:
			#match export_settings.export_type:
				#ExportSettings.ExportType.EXR or ExportSettings.ExportType.JPG or ExportSettings.ExportType.PNG:
			#pass

func export_web(captures: Array[Image]) -> void:
	var writer := ZIPPacker.new()
	writer.open("user://export.zip")
	var extension := (ExportSettings.ExportType.keys()[export_settings.export_type] as String).to_lower()
	for i in captures.size():
		var capture := captures[i]
		
		writer.start_file("export-%s.%s" % [i, extension])
		
		match export_settings.export_type:
			ExportSettings.ExportType.EXR:
				writer.write_file(capture.save_exr_to_buffer())
			ExportSettings.ExportType.JPG:
				writer.write_file(capture.save_jpg_to_buffer())
			ExportSettings.ExportType.PNG:
				writer.write_file(capture.save_png_to_buffer())
		
		writer.close_file()
	writer.close()
	var file := FileAccess.open("user://export.zip", FileAccess.READ)
	JavaScriptBridge.download_buffer(file.get_buffer(file.get_length()), "export.zip", "zip")


func _on_export_settings_changed() -> void:
	export_settings.save()

func _on_render_settings_changed() -> void:
	render_settings.save()
	apply_render_settings(Global.render_settings)





#func export_webp(captures: Array[Image]) -> void:
	#var frame_delay := Global.render_settings.duration / Global.render_settings.frame_count
	#
	#var array : Array[PackedByteArray] = []
	#for capture in captures:
		#capture.convert(Image.FORMAT_RGBA8)
		#array.append(capture.get_data())
	#var width := Global.render_settings.resolution.x
	#var height := Global.render_settings.resolution.y
	#var path := Global.export_settings.export_path + ".webp"
	#
	#var error := AnimationExporter.export_webp(path, width, height, frame_delay, array) as Error
	#assert(error == OK, "Webp export failed with code: %s" % error)

#func export_gif(captures: Array[Image]) -> void:
	#var frame_delay := Global.render_settings.duration / Global.render_settings.frame_count
	#
	#var array : Array[PackedByteArray] = []
	#for capture in captures:
		#capture.convert(Image.FORMAT_RGBA8)
		#array.append(capture.get_data())
	#var width := Global.render_settings.resolution.x
	#var height := Global.render_settings.resolution.y
	#var path := Global.export_settings.export_path + ".gif"
	#
	#var error := AnimationExporter.export_gif(path, width, height, frame_delay, array) as Error
	#assert(error == OK, "GIF export failed with code: %s" % error)
