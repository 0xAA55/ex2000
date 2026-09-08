#version 330

uniform mat4 camorient;
uniform mat4 proj;
uniform vec3 campos;
uniform sampler2D normal_distance;
uniform sampler2D diffuse;
uniform sampler2D specular;
uniform sampler2D emissive;
uniform sampler2D scatter;
uniform float render_distance;

uniform vec3 sunpos;
uniform vec3 ambcolor;
uniform vec3 suncolor;

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

	vec3 refl = reflect(-sunpos, normal);
	vec3 halfway = normalize(refl - fragdir);

	vec3 diffuse = ss_diffuse.xyz * vec3(mix(ambcolor, suncolor, max(dot(normal, sunpos), 0.0)));
	vec3 specular = ss_specular.xyz * pow(max(0.0, dot(halfway, normal)), ss_specular.w);
	vec3 surface = diffuse + specular + ss_emissive.xyz;

	color = vec4(mix(surface, ss_scatter.xyz, ss_scatter.w), 1.0);
}
