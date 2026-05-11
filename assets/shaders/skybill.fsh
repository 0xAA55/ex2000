#version 330

uniform mat4 camera;
uniform float aspect;
uniform float fovy;
uniform float time;
uniform sampler2D noise;
uniform vec4 fogcolor = vec4(0.8, 0.9, 1.0, 1.0);
uniform vec4 skycolor = vec4(0.1, 0.2, 0.8, 1.0);
in vec2 texcoord;
out vec4 color;

void main()
{
	vec2 uv = texcoord * 2.0 - 1.0;
	uv.x *= aspect;
	vec3 fragdir = vec3(uv * fovy, 1.0);
	fragdir *= mat3(camera);
	fragdir = normalize(fragdir);


	if (fragdir.y >= 0.0)
	{
		color = mix(fogcolor, skycolor, fragdir.y);
		vec2 cloud_uv = fragdir.xz * 0.5 / fragdir.y;
		float dist = length(cloud_uv);
		float cloud = texture2D(noise, cloud_uv + time * 0.05).r * 0.5 + 0.5;
		float fog = 1.0 / max(1.0, dist);
		color = mix(color, vec4(1.0), cloud * fog * fog * fog);
	}
	else
	{
		color = mix(fogcolor, vec4(0.0), -fragdir.y);
	}
}
