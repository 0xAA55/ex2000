#version 330

uniform float progress;
in vec2 texcoord;
out vec4 color;

const vec2 VirtualResolution = vec2(640.0, 480.0);
const vec2 BarSize = vec2(480.0, 3.0);

void main()
{
	vec2 xy = texcoord * VirtualResolution;
	vec2 bar_pos = VirtualResolution * 0.5 - BarSize * 0.5;
	vec2 xy_rel_bar = (xy - bar_pos) / BarSize;
	vec2 bar_distance = max(vec2(0.0), ((BarSize * 0.5) - abs(xy - VirtualResolution * 0.5)) / (BarSize * 0.5));
	float bar = pow(bar_distance.x * bar_distance.y, 0.01);
	color = mix(vec4(0.0), mix(vec4(0.2), vec4(1.0), pow(min(1.0, max(0.0, progress - xy_rel_bar.x)), 0.1)), bar);
}
