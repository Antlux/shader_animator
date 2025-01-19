class_name ExportSettings extends Resource

const PATH := "user://export_settings.tres"

enum ExportType {
	EXR,
	JPG,
	PNG,
	WEBP,
	GIF,
	SPRITESHEET,
}

@export var export_type := ExportType.PNG: 
	set(value):
		export_type = value
		emit_changed()
@export var duration: float = 1.0:
	set(value):
		duration = maxf(0, value)
		emit_changed()
@export var frame_count: float = 30.0:
	set(value):
		frame_count = maxf(1, value)
		emit_changed()
@export var resolution: Vector2i = Vector2i(512, 512):
	set(value):
		resolution = Vector2i.ZERO.max(value)
		emit_changed()
@export var export_path: String = "/" :
	set(value):
		export_path = value
		emit_changed()

func save() -> void:
	var error = ResourceSaver.save(self, PATH)
	assert(error == OK, "Could not save export settings.")

static func load_or_create() -> ExportSettings:
	if ResourceLoader.exists(PATH, "ExportSettings"):
		return ResourceLoader.load(PATH)
	return ExportSettings.new()
