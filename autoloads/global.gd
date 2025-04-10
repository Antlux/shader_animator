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
		new_animation.save()
		shader_animation_list_updated.emit()

func duplicate_shader_animation(shader_animation: ShaderAnimation, animation_name: String) -> void:
	if not animation_name.is_empty():
		var duplicate_animation : ShaderAnimation = shader_animation.duplicate(true)
		duplicate_animation.name = animation_name
		shader_animation_list.append(duplicate_animation)
		duplicate_animation.save()
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


func export_zip(path: String, captures: Array[Image], export_type: ExportSettings.ExportTypes) -> Error:
	var extension :=  ExportSettings.get_extension(export_settings.export_type)
	var zip_packer := ZIPPacker.new()
	
	var opening_error := zip_packer.open(path)
	
	if opening_error != OK:
		return opening_error
	
	for idx in captures.size():
		var capture := captures[idx]
		var file_name := "export-%s.%s" % [idx, extension]
		
		var start_file_error := zip_packer.start_file(file_name)
		if start_file_error != OK:
			return start_file_error
		
		var write_file_error: Error
		match export_type:
			ExportSettings.ExportTypes.PNG:
				write_file_error = zip_packer.write_file(capture.save_png_to_buffer())
			ExportSettings.ExportTypes.JPG:
				write_file_error = zip_packer.write_file(capture.save_jpg_to_buffer())
			ExportSettings.ExportTypes.EXR:
				write_file_error = zip_packer.write_file(capture.save_exr_to_buffer())
		if write_file_error != OK:
			return write_file_error
		
		var close_file_error := zip_packer.close_file()
		if close_file_error != OK:
			return close_file_error
		
	var close_error := zip_packer.close()
	if close_error != OK:
		return close_error
	
	return OK

func generate_gif_buffer(captures: Array[Image]) -> PackedByteArray:
	if not captures.size() > 0:
		return []
	
	var width := captures[0].get_width()
	var height := captures[0].get_height()
	var delay := render_settings.duration / render_settings.frame_count
	var array_buffer: Array[PackedByteArray] = []
	for capture in captures:
		capture.convert(Image.FORMAT_RGBA8)
		array_buffer.append(capture.get_data())
	return AnimationExporter.encode_gif(width, height, delay, array_buffer)



func export(captures: Array[Image]) -> void:
	var split_path := Global.export_settings.export_path.rsplit(".", true, 1) as PackedStringArray
	var stem := split_path[0]
	var extension := split_path[1]
	
	match export_settings.export_type:
		ExportSettings.ExportTypes.EXR: 
			for idx in captures.size():
				var capture := captures[idx]
				var path := stem + ("-%s." % idx) + extension
				var error : Error = capture.save_exr(path)
				assert(error == OK, "Could not save as %s" % extension)
		ExportSettings.ExportTypes.JPG:
			for idx in captures.size():
				var capture := captures[idx]
				var path := stem + ("-%s." % idx) + extension
				var error : Error = capture.save_jpg(path)
				assert(error == OK, "Could not save as %s" % extension)
		ExportSettings.ExportTypes.PNG:
			for idx in captures.size():
				var capture := captures[idx]
				var path := stem + ("-%s." % idx) + extension
				var error : Error = capture.save_png(path)
				assert(error == OK, "Could not save as %s" % extension)
		ExportSettings.ExportTypes.GIF:
			var file := FileAccess.open(Global.export_settings.export_path, FileAccess.WRITE)
			if file:
				file.store_buffer(generate_gif_buffer(captures))
				file.close()

func export_web(captures: Array[Image]) -> void:
	var extension := ExportSettings.get_extension(export_settings.export_type)
	
	match export_settings.export_type:
		ExportSettings.ExportTypes.GIF:
			JavaScriptBridge.download_buffer(generate_gif_buffer(captures), "export.gif", "gif")
		var export_type:
			var export_error := export_zip("user://export.zip", captures, export_type)
			if export_error != OK : printerr(error_string(export_error))
			var zip_file := FileAccess.open("user://export.zip", FileAccess.READ)
			var zip_buffer := zip_file.get_buffer(zip_file.get_length())
			JavaScriptBridge.download_buffer(zip_buffer, "export.zip", "zip")

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
