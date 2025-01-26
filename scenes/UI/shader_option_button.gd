extends OptionButton

const SHADER_FACES_PATH := "res://resources/custom/ShaderFace/shader_faces/"

@export var shader_faces : Array[ShaderFace] = []


func _ready() -> void:
	setup()
	item_selected.connect(_on_item_selected)
	select(0)
	select_shader(0)


func setup() -> void:
	for idx in shader_faces.size():
		add_item(shader_faces[idx].name, idx)


func _on_item_selected(idx: int) -> void:
	select_shader(idx)


func select_shader(idx: int) -> void:
	var shader_material = shader_faces[idx].shader_material
	Render.render_material = shader_material
