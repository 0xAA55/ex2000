#version 330

uniform float time;
uniform vec4 fogcolor = vec4(0.8, 0.9, 1.0, 1.0);
uniform vec4 suncolor = vec4(1.0, 0.9, 0.8, 1.0);
uniform vec3 sunpos = normalize(vec3(1.0, 1.0, 1.0));
uniform sampler2D terrain;

in vec3 frag_normal;
in vec2 texcoord;

out vec4 color;

void main()
{
	// color = vec4(texture2D(terrain, texcoord).r);
	vec3 normal = normalize(frag_normal);
	color = vec4(normal * 0.5 + 0.5, 1.0);
}
