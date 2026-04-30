#version 330

uniform mat4 camera;
uniform float aspect;
uniform float fovy;
in vec2 texcoord;
out vec4 color;

void main()
{
	vec2 uv = texcoord * 2.0 - 1.0;
	uv.x *= aspect;
	vec3 position = vec3(uv * fovy, 1.0);
	position *= mat3(camera);
	position = min(max(normalize(position) * 10.0, vec3(-1.0)), vec3(1.0)) * 0.5 + 0.5;
	color = vec4(position, 1.0);
}
