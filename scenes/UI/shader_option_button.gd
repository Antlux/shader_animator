extends OptionButton

func _ready() -> void:
	setup()
	update_list()
	if Global.shader_animation_list.size() > 0:
		select(0)
		select_shader(0)


func setup() -> void:
	Global.shader_animation_list_updated.connect(_on_shader_animation_list_updated)
	ShaderAnimationRenderer.started_rendering.connect(_on_started_rendering)
	ShaderAnimationRenderer.ended_rendering.connect(_on_ended_rendering)
	item_selected.connect(_on_item_selected)

func update_list() -> void:	
	clear()

	for anim_idx in Global.shader_animation_list.size():
		add_icon_item(Global.shader_animation_list[anim_idx].get_texture(Vector2i(64, 64)), Global.shader_animation_list[anim_idx].name)

func select_shader(idx: int) -> void:
	idx = clampi(idx, -1, Global.shader_animation_list.size() - 1)
	
	if idx < 0:
		ShaderAnimationRenderer.change_shader_animation(null)
		return
	
	ShaderAnimationRenderer.change_shader_animation(Global.shader_animation_list[idx])


func _on_shader_animation_list_updated() -> void:
	var idx := selected
	
	update_list()
	
	var count := Global.shader_animation_list.size()
	
	print(count)
	
	if count > 0:
		idx = maxi(0, idx - 1)
	else:
		idx = maxi(-1, idx - 1)
	
	print(idx)
	
	select(idx)
	select_shader(idx)

func _on_started_rendering() -> void:
	disabled = true

func _on_ended_rendering() -> void:
	disabled = false

func _on_item_selected(idx: int) -> void:
	select_shader(idx)
