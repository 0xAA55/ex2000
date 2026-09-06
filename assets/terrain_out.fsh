#version 330

uniform vec3 campos;
uniform float render_distance;
in vec2 texcoord;
out vec4 out_normal_dist;
out vec4 out_diffuse;
out vec4 out_specular;
out vec4 out_emissive;
out vec4 out_scatter;

const float flt_max = 3.40282347E+38;

float get_z(vec3 ray, float dist);
vec3 get_fragdir(vec2 uv);
bool raymarch_terrain(vec3 start, vec3 dir, float max_dist, out float dist);
vec3 get_terrain_normal(vec3 pos, float e);

void main()
{
	vec3 fragdir = get_fragdir(texcoord);
	float ray_dist;
	if (raymarch_terrain(campos, fragdir, render_distance, ray_dist))
	{
		vec3 hitpos = campos + fragdir * ray_dist;
		gl_FragDepth = get_z(fragdir, ray_dist);
		out_normal_dist = vec4(get_terrain_normal(hitpos, 1.0), ray_dist);
		out_diffuse = vec4(1.0);
		out_specular = vec4(1.0, 1.0, 1.0, 10.0);
		out_emissive = vec4(0.0);
		out_scatter = vec4(1.0);
	}
	else
	{
		gl_FragDepth = 1.0;
		out_normal_dist = vec4(fragdir, flt_max);
		out_diffuse = vec4(1.0);
		out_specular = vec4(0.0, 0.0, 0.0, 1.0);
		out_emissive = vec4(0.0);
		out_scatter = vec4(1.0);
	}
}
