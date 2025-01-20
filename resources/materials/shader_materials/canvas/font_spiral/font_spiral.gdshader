shader_type canvas_item;

group_uniforms effect;
uniform float outside_time = 0.0;
uniform float speed = 1.0;
uniform float frequency = 8.0;

group_uniforms font_art;
uniform vec4 foreground_color: source_color = vec4(1);
uniform vec4 background_color: source_color = vec4(vec3(0), 1);
uniform int empty_cells : hint_range(0, 1000, 1) = 0;
uniform ivec2 cell_size = ivec2(8);
uniform ivec2 cell_offset = ivec2(0);
uniform ivec2 padding = ivec2(0);
uniform float scale = 1.0;
uniform sampler2D font_texture: hint_default_black, filter_nearest, repeat_disable;

vec2 get_cell_uv(vec2 uv, vec2 screen_size) {
	vec2 cell_factor_padded = screen_size / (vec2(cell_size + padding) * scale);
	return floor(uv  * cell_factor_padded) / cell_factor_padded;
}

vec2 get_cell_relative_uv(vec2 uv, vec2 screen_size) {
	vec2 cell_factor = screen_size / (vec2(cell_size) * scale);
	vec2 cell_factor_padded = screen_size / (vec2(cell_size + padding) * scale);
	return fract(uv * cell_factor_padded) * (cell_factor / cell_factor_padded);
}

vec4 get_font_color(vec2 cell_uv, vec2 cell_relative_uv, float luminosity) {
	ivec2 texture_size = textureSize(font_texture, 0);
	ivec2 texture_dims = texture_size / cell_size;
	int cell_count = texture_dims.x * texture_dims.y - empty_cells;
	int cell_index = int(round(luminosity * float(cell_count)));
	int cell_x = cell_index % texture_dims.x;
	int cell_y = (cell_index - cell_x) / texture_dims.x;
	vec2 cell_pos = vec2(ivec2(cell_x, cell_y)) / vec2(texture_dims);

	vec2 cell_texture_uv = (cell_pos) + cell_relative_uv / vec2(texture_dims);
	return texture(font_texture, cell_texture_uv);
}


float draw_spiral(vec2 uv, float rotation) {
	float uv_radius = length(uv);
	float uv_phi = atan(uv.y, uv.x) + rotation;
	float spiral_phi = (log(uv_radius) * frequency - uv_phi) / TAU;
	float spiral_radius = exp((TAU * floor(spiral_phi) + uv_phi) / frequency);
	return spiral_radius;
}


//
void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;

	vec2 uv = SCREEN_UV - .5;
	vec2 cell_uv = get_cell_uv(uv, screen_size);

	vec2 uv_offset = SCREEN_UV - vec2(cell_offset) * SCREEN_PIXEL_SIZE * scale;
	vec2 cell_relative_uv_offset = get_cell_relative_uv(uv_offset, screen_size);
	vec2 cell_uv_offset = get_cell_uv(uv_offset, screen_size);

	float f_speed = outside_time * speed;
	
	float cell_lum = draw_spiral(cell_uv, outside_time * speed * TAU);

	float font_mask = get_font_color(cell_uv_offset, cell_relative_uv_offset, cell_lum).x;

	float cell_mask = clamp(1.0 - floor(max(cell_relative_uv_offset.x, cell_relative_uv_offset.y)), 0, 1);
	font_mask = mix(0.0, font_mask, cell_mask);

	COLOR = mix(background_color, foreground_color, font_mask);
	//COLOR.rgb = vec3(cell_lum);
}