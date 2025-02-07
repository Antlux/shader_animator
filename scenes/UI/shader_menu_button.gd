extends MenuButton

@export var creation_text_input_dialog: TextInputDialog
@export var import_file_dialog: FileDialog
@export var export_file_dialog: FileDialog
@export var deletion_confirmation_dialog: ConfirmationDialog

enum ShaderActions {
	CREATE,
	IMPORT,
	EXPORT,
	DUPLICATE,
	DELETE,
	RESET
}

func _ready() -> void:
	for idx in ShaderActions.size():
		get_popup().add_item(ShaderActions.keys()[idx], ShaderActions.values()[idx])
	
	get_popup().id_pressed.connect(_on_action_pressed)
	
	creation_text_input_dialog.text_submitted.connect(_on_creation_text_submitted)
	import_file_dialog.files_selected.connect(_on_import_files_selected)
	export_file_dialog.file_selected.connect(_on_export_file_selected)
	deletion_confirmation_dialog.confirmed.connect(_on_deletion_confirmed)


func _on_action_pressed(action: ShaderActions) -> void:
	var action_prompt: String = ShaderActions.keys()[action]
	print(action_prompt)
	match action:
		ShaderActions.CREATE:
			creation_text_input_dialog.popup()
		ShaderActions.IMPORT:
			import_file_dialog.title = "Import a Shader Animation"
			import_file_dialog.current_path = Global.export_settings.export_path.rsplit("/", true, 1)[0] + "/"
			import_file_dialog.clear_filters()
			import_file_dialog.add_filter("*.tres", "shader animation")
			import_file_dialog.popup()
		ShaderActions.EXPORT:
			export_file_dialog.title = "Export a Shader Animation"
			export_file_dialog.current_path = Global.export_settings.export_path.rsplit("/", true, 1)[0] + "/"
			export_file_dialog.clear_filters()
			export_file_dialog.add_filter("*.tres", "shader animation")
			export_file_dialog.popup()
		ShaderActions.DUPLICATE:
			pass
		ShaderActions.DELETE:
			deletion_confirmation_dialog.dialog_text = "Are you sure you want to delete '%s'?" % ShaderAnimationRenderer.shader_animation.name
			deletion_confirmation_dialog.popup()
		ShaderActions.RESET:
			Global.reset_shader_animations()


func _on_import_files_selected(paths: PackedStringArray) -> void:
	for path in paths:
		print("Importing %s" % path)

func _on_export_file_selected(path: String) -> void:
	print("Exporting X to %s" % path)

func _on_deletion_confirmed() -> void:
	Global.remove_shader_animation(ShaderAnimationRenderer.shader_animation)

func _on_creation_text_submitted(new_text: String) -> void:
	Global.add_shader_animation(new_text)
