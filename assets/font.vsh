#version 330

uniform sampler2D font_map;
uniform vec2 resolution;
uniform float font_size;
uniform vec2 offset;
in vec2 position;
in vec2 xy;
in vec2 wh;
in vec2 txy;
in vec2 twh;

out vec2 uv;

void main()
{
	uv = ((position * twh) + txy * font_size) / vec2(textureSize(font_map, 0));
	gl_Position = vec4(((((position * wh) + xy + offset) / resolution) * 2.0 - 1.0) * vec2(1.0, -1.0), 0.0, 1.0);
}
