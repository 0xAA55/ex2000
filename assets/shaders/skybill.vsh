#version 330

in vec2 position;
out vec2 texcoord;

void main()
{
	texcoord = position;
	gl_Position = vec4(position * 2.0 - 1.0, 0.0, 1.0);
}
