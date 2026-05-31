#version 330

uniform mat4 transform;

in vec3 position;
in vec3 normal;
in vec2 uv;

out vec3 frag_normal;
out vec2 texcoord;

void main()
{
	texcoord = uv;
	frag_normal = normal;
	gl_Position = transform * vec4(position, 1.0);
}
