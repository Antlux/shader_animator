extends Label

@export var render_container: Control


func _ready() -> void:
	render_container.camera_zoom_changed.connect(_on_camera_zoom_changed)

func _on_camera_zoom_changed() -> void:
	text = "Zoom : ( %.2f - %.2f )" % [render_container.camera.zoom.x, render_container.camera.zoom.y]
