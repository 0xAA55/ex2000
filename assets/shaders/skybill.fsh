#version 330

uniform mat4 camera;
uniform float aspect;
in vec2 texcoord;
out vec4 color;

void main()
{
	vec2 uv = texcoord * 2.0 - 1.0;
	uv.x *= aspect;
	vec3 position = vec3(uv, 1.0);
	position *= mat3(camera);
	position = normalize(position);// * 0.5 + 0.5;
	color = vec4(position, 1.0);
}
