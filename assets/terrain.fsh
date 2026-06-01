#version 330

uniform mat4 view;
uniform float time;
uniform vec4 fogcolor = vec4(0.8, 0.9, 1.0, 1.0);
uniform vec4 suncolor = vec4(1.0, 0.9, 0.8, 1.0);
uniform vec3 sunpos = normalize(vec3(1.0, 1.0, 1.0));
uniform float fog_distance = 1500.0;
uniform sampler2D terrain;

in vec3 frag_position;
in vec3 frag_normal;
in vec2 texcoord;
in mat4 transform;

out vec4 color;

void main()
{
	float height = texture2D(terrain, texcoord).r;
	vec3 normal = normalize(frag_normal);
	float light = max(0.0, dot(sunpos, normal));
	vec3 diffuse = mix(suncolor.xyz, fogcolor.xyz * 0.5, light);
	float distance = length(frag_position);
	color = mix(vec4(diffuse, 1.0), fogcolor, min(distance / fog_distance, 1.0));
}
