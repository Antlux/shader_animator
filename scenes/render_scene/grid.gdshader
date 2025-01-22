shader_type canvas_item;

uniform vec3 cell_color: source_color = vec3(1.0);
uniform vec3 line_color: source_color = vec3(0.0);
uniform vec2 cell_size = vec2(8.0);
uniform float line_width = 1.0;
uniform vec2 offset = vec2(0.0);


void fragment() {;
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 cell_factor = screen_size / (cell_size);
	vec2 uv_lined = fract(SCREEN_UV * cell_factor) * cell_size / (cell_size - line_width);
	float mask = step(max(uv_lined.x, uv_lined.y), 1.0);
	COLOR.rgb = mix(line_color, cell_color, mask);
	
}