shader_type canvas_item;

uniform sampler2D noise: hint_default_black, filter_linear, repeat_enable;
uniform vec2 pixelisation_amount = vec2(1.0);

const mat4 dither = mat4(
	vec4(0.0, 0.5333333333, 0.1333333333,  0.6666666667),
	vec4(0.8, 0.2666666667, 0.9333333333,  0.4),
	vec4(0.2, 0.7333333333, 0.06666666667, 0.6),
	vec4(1.0, 0.4666666667, 0.8666666667,  0.3333333333)
);


void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 factor =  screen_size / pixelisation_amount;
	vec2 pixel_uv = floor(UV * factor) / factor;
	COLOR = texture(noise, pixel_uv);
}