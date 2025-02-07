class_name TextInputDialog extends PopupPanel

@export var line_edit: LineEdit
@export var confirm_button: Button
@export var cancel_button: Button

signal text_submitted(new_text: String)


func _ready() -> void:
	about_to_popup.connect(_on_about_to_popup)
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func _on_about_to_popup() -> void:
	line_edit.clear()
	line_edit.grab_focus()

func _on_line_edit_text_submitted(new_text: String) -> void:
	text_submitted.emit(new_text)
	hide()

func _on_line_edit_text_changed(new_text: String) -> void:
	confirm_button.disabled = new_text.is_empty()

func _on_confirm_pressed() -> void:
	if not line_edit.text.is_empty():
		text_submitted.emit(line_edit.text)
	hide()

func _on_cancel_pressed() -> void:
	hide()
