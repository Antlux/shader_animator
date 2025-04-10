class_name ExportSettings extends Resource

const PATH := "user://export_settings.tres"

enum ExportTypes {
	EXR,
	JPG,
	PNG,
	GIF,
}

@export var export_type := ExportTypes.PNG: 
	set(value):
		export_type = value
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

static func get_extension(export_type: ExportTypes) -> String:
	return (ExportSettings.ExportTypes.keys()[export_type] as String).to_lower()
