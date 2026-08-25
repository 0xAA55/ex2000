#version 330

uniform mat4 camorient;
uniform mat4 proj;
uniform vec3 campos;
uniform sampler2D normal_distance;
uniform sampler2D diffuse;
uniform sampler2D specular;
uniform sampler2D emissive;
uniform sampler2D scatter;

in vec2 texcoord;
out vec4 color;

mat3 view_rot_inv = inverse(mat3(camorient));

float get_z(vec3 ray, float dist)
{
	vec3 zdir = view_rot_inv * (ray * dist);
	vec4 clip = proj * vec4(zdir, 1.0);
	float ndc_z = clip.z / clip.w;
	return ndc_z * 0.5 + 0.5;
}

void main()
{
	vec4 ndc = vec4(texcoord * 2.0 - 1.0, 1.0, 1.0);
	vec4 camdir_z = inverse(proj) * ndc;
	vec3 fragdir = normalize(mat3(camorient) * camdir_z.xyz);

	vec4 ss_nd = texture2D(normal_distance, texcoord);
	vec4 ss_diffuse = texture2D(diffuse, texcoord);
	vec4 ss_specular = texture2D(specular, texcoord);
	vec4 ss_emissive = texture2D(emissive, texcoord);
	vec4 ss_scatter = texture2D(scatter, texcoord);

	color = vec4(ss_nd.xyz, 1.0);
	gl_FragDepth = get_z(fragdir, ss_nd.w);
}
