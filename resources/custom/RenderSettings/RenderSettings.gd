class_name RenderSettings extends Resource

const PATH := "user://render_settings.tres"

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

func save() -> void:
	var error = ResourceSaver.save(self, PATH)
	assert(error == OK, "Could not save export settings.")

static func load_or_create() -> RenderSettings:
	if ResourceLoader.exists(PATH, "RenderSettings"):
		return ResourceLoader.load(PATH)
	return RenderSettings.new()
