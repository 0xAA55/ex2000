#version 330

uniform sampler2D font_map;
uniform vec4 font_color = vec4(1.0);
in vec2 uv;
out vec4 color;

void main()
{
	vec4 sampled = vec4(1.0, 1.0, 1.0, texture2D(font_map, uv).r);
	color = sampled * font_color;
}
