#version 330

uniform mat4 camorient;
uniform mat4 proj;

mat3 view_rot_inv = inverse(mat3(camorient));

float get_z(vec3 ray, float dist)
{
	vec3 zdir = view_rot_inv * (ray * dist);
	vec4 clip = proj * vec4(zdir, 1.0);
	float ndc_z = clip.z / clip.w;
	return ndc_z * 0.5 + 0.5;
}

vec3 get_fragdir(vec2 uv)
{
	vec4 ndc = vec4(uv * 2.0 - 1.0, 1.0, 1.0);
	vec4 camdir_z = inverse(proj) * ndc;
	return normalize(mat3(camorient) * camdir_z.xyz);
}
