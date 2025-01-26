extends MenuButton

@export var grid: Grid

enum GridElements {
	X_AXIS,
	Y_AXIS,
	GRID_LINES,
	GRID_UNITS,
}

func _ready() -> void:
	setup()
	get_popup().index_pressed.connect(_on_index_pressed)

func setup() -> void:
	for idx in GridElements.size():
		var key: String = GridElements.keys()[idx]
		var value: GridElements = GridElements.values()[idx]
		get_popup().add_check_item(key.replace("_", " ").to_lower().capitalize(), value)
		get_popup().set_item_checked(value, is_element_drawn(value))

func is_element_drawn(element: GridElements) -> bool:
	match element:
		GridElements.X_AXIS:
			return grid.draw_x_axis
		GridElements.Y_AXIS:
			return grid.draw_y_axis
		GridElements.GRID_LINES:
			return grid.draw_grid_lines
		GridElements.GRID_UNITS:
			return grid.draw_grid_units
	return false

func set_element_drawn(element: GridElements, draw: bool) -> void:
	match element:
		GridElements.X_AXIS:
			grid.draw_x_axis = draw
		GridElements.Y_AXIS:
			grid.draw_y_axis = draw
		GridElements.GRID_LINES:
			grid.draw_grid_lines = draw
		GridElements.GRID_UNITS:
			grid.draw_grid_units = draw
	


func _on_index_pressed(idx: int) -> void:
	var id: GridElements = get_popup().get_item_id(idx)
	var current := get_popup().is_item_checked(idx)
	set_element_drawn(id, !current)
	get_popup().set_item_checked(idx, is_element_drawn(id))
	
	
	
