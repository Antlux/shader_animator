extends PanelContainer

@export var resolution_x_spin_box: SpinBox
@export var resolution_y_spin_box: SpinBox
@export var duration_spinbox: SpinBox
@export var frame_count_spin_box: SpinBox



func _ready() -> void:
	update_values()
	
	resolution_x_spin_box.value_changed.connect(_on_resolution_x_changed)
	resolution_y_spin_box.value_changed.connect(_on_resolution_y_changed)
	duration_spinbox.value_changed.connect(_on_duration_changed)
	frame_count_spin_box.value_changed.connect(_on_frame_count_changed)
	
	Global.export_settings.changed.connect(_on_export_settings_changed)

func update_values() -> void:
	resolution_x_spin_box.set_value_no_signal(Global.export_settings.resolution.x)
	resolution_y_spin_box.set_value_no_signal(Global.export_settings.resolution.y)
	duration_spinbox.set_value_no_signal(Global.export_settings.duration)
	frame_count_spin_box.set_value_no_signal(Global.export_settings.frame_count)


func _on_export_settings_changed() -> void:
	update_values()


func _on_resolution_x_changed(value: float) -> void:
	var current_res := Global.export_settings.resolution
	current_res.x = value as int
	Global.export_settings.resolution = current_res

func _on_resolution_y_changed(value: float) -> void:
	var current_res := Global.export_settings.resolution
	current_res.y = value as int
	Global.export_settings.resolution = current_res

func _on_duration_changed(value: float) -> void:
	Global.export_settings.duration = value

func _on_frame_count_changed(value: float) -> void:
	Global.export_settings.frame_count = value
