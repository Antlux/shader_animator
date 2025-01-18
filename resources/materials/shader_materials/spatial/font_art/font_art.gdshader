shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D font_texture: hint_default_black, filter_nearest, repeat_disable;

uniform ivec2 cell_size = ivec2(8);
uniform int empty_cells : hint_range(0, 1000, 1) = 0;
uniform float scale = 1.0;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	 return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


void fragment() {
	ivec2 texture_size = textureSize(font_texture, 0);
	ivec2 texture_dims = texture_size / cell_size;
	int cell_count = texture_dims.x * texture_dims.y - empty_cells;
	vec2 cell_factor = VIEWPORT_SIZE / (vec2(cell_size) * scale);
	vec2 cell_uv = floor(SCREEN_UV * cell_factor) / cell_factor;
	vec2 cell_relative_uv = fract(SCREEN_UV * cell_factor);

	vec3 cell_color = texture(SCREEN_TEXTURE, cell_uv).rgb;
	vec3 cell_color_hsv = rgb2hsv(cell_color);
	vec3 cell_saturated_color = hsv2rgb(vec3(cell_color_hsv.x, cell_color_hsv.y, .5));
	float cell_lum = clamp(cell_color_hsv.z, 0.0, 1.0);


	int cell_index = int(cell_lum * float(cell_count));
	int cell_x = cell_index % texture_dims.x;
	int cell_y = (cell_index - cell_x) / texture_dims.x;
	vec2 cell_pos = vec2(ivec2(cell_x, cell_y)) / vec2(texture_dims);
	vec2 cell_texture_uv = cell_pos + cell_relative_uv / vec2(texture_dims);

	vec3 font_color = texture(font_texture, cell_texture_uv).x * cell_saturated_color;

	ALBEDO = font_color;
}
