#version 330

uniform vec3 campos;
uniform float render_distance;
uniform float fog_density;
in vec2 texcoord;
out vec4 out_normal_dist;
out vec3 out_diffuse;
out vec4 out_specular;
out vec3 out_emissive;
out vec4 out_fog;

const float flt_max = 3.40282347E+38;

float get_z(vec3 ray, float dist);
vec3 get_fragdir(vec2 uv);

bool raymarch_terrain(vec3 start, vec3 dir, float max_dist, out float dist);
vec3 get_terrain_normal(vec3 pos, float e);
vec3 get_terrain_basecolor(vec3 pos);
vec4 get_terrain_specular(vec3 pos);

vec3 get_fog_color();
vec3 get_sky_color(vec3 pos, vec3 ray);

void main()
{
	vec3 fragdir = get_fragdir(texcoord);
	float ray_dist;
	vec3 sky_color = get_sky_color(campos, fragdir);
	if (raymarch_terrain(campos, fragdir, render_distance, ray_dist))
	{
		float fog_thickness = min(1.0, ray_dist * fog_density);
		vec3 hitpos = campos + fragdir * ray_dist;
		gl_FragDepth = get_z(fragdir, ray_dist);
		out_normal_dist = vec4(get_terrain_normal(hitpos, 1.0), ray_dist);
		out_diffuse = get_terrain_basecolor(hitpos);
		out_specular = get_terrain_specular(hitpos);
		out_emissive = vec3(0.0);
		out_fog = vec4(get_fog_color(), fog_thickness);
	}
	else
	{
		gl_FragDepth = 1.0;
		out_normal_dist = vec4(fragdir, flt_max);
		out_diffuse = vec3(0.0);
		out_specular = vec4(0.0, 0.0, 0.0, 1.0);
		out_emissive = vec3(0.0);
		out_fog = vec4(sky_color, 1.0);
	}
}
