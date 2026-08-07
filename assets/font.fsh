#version 330

uniform sampler2D font_map;
uniform vec4 font_color = vec4(1.0);
uniform vec4 bkgr_color = vec4(0.0);
in vec2 uv;
flat in int is_bg;
out vec4 color;

void main()
{
	float fa = texture2D(font_map, uv).r;
	if (is_bg != 0) color = bkgr_color;
	else color = vec4(font_color.xyz, font_color.w * fa);
}
