#version 330

uniform sampler2D font_map;
uniform vec2 resolution;
uniform int grid_size;
uniform vec2 offset;
in vec2 position;
in vec2 xy;
in vec2 wh;
in ivec2 txy;
in ivec2 twh;

flat out int is_bg;
out vec2 uv;

void main()
{
	uv = ((position * vec2(twh)) + vec2(txy * grid_size)) / vec2(textureSize(font_map, 0));
	is_bg = (twh.x | twh.y) == 0 ? 1 : 0;
	gl_Position = vec4(((((position * wh) + xy + offset) / resolution) * 2.0 - 1.0) * vec2(1.0, -1.0), 0.0, 1.0);
}
