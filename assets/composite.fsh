#version 330

uniform mat4 camorient;
uniform mat4 proj;
uniform vec3 campos;
uniform sampler2D normal_distance;
uniform sampler2D diffuse;
uniform sampler2D specular;
uniform sampler2D emissive;
uniform sampler2D scatter;
uniform float render_distance = 3000.0;
uniform vec3 sunpos;

in vec2 texcoord;
out vec4 color;

float get_z(vec3 ray, float dist);
vec3 get_fragdir(vec2 uv);

void main()
{
	vec3 fragdir = get_fragdir(texcoord);

	vec4 ss_nd = texture2D(normal_distance, texcoord);
	vec4 ss_diffuse = texture2D(diffuse, texcoord);
	vec4 ss_specular = texture2D(specular, texcoord);
	vec4 ss_emissive = texture2D(emissive, texcoord);
	vec4 ss_scatter = texture2D(scatter, texcoord);

	vec3 normal = ss_nd.xyz;
	vec3 position = campos + normal * ss_nd.w;
	gl_FragDepth = get_z(fragdir, ss_nd.w);

	color = vec4(normal, 1.0);
}
