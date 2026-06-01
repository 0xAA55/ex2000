#version 330

uniform mat4 view;
uniform mat4 proj;

in vec3 position;
in vec3 normal;
in vec2 uv;
in mat4 transform;

out vec3 frag_normal;
out vec2 texcoord;
out vec3 frag_position;

void main()
{
	texcoord = uv;
	frag_normal = normal;
	frag_position = (view * transform * vec4(position, 1.0)).xyz;
	gl_Position = proj * view * transform * vec4(position, 1.0);
}
