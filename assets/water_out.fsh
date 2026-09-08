#version 330

const int num_waves_surface = 12;
const int num_waves_normal = num_waves_surface * 2;
const int num_waves_caustic = num_waves_normal;

uniform vec3 campos;

uniform sampler2D terrain_normal_depth;
uniform float render_distance;

uniform float sea_level;
uniform float sea_wave_height;

in vec2 texcoord;
out vec4 out_normal_dist;
out vec4 out_diffuse;
out vec4 out_specular;
out vec4 out_emissive;
out vec4 out_scatter;

float get_water_height(vec2 pos, int num_waves, float phase_shift);
bool raymarch_water(vec3 start, vec3 dir, float max_dist, out float dist);
bool raymarch_water_underwater(vec3 start, vec3 dir, float max_dist, out float dist);
vec3 get_water_normal(vec3 pos, float e, int num_waves, float phase_shift);

bool raymarch_terrain(vec3 start, vec3 dir, float max_dist, out float dist);
vec3 get_terrain_normal(vec3 pos, float e);

vec3 get_sky_color(vec3 pos, vec3 ray);

float get_z(vec3 ray, float dist);
vec3 get_fragdir(vec2 uv);

void main()
{
	bool is_underwater = false;
	vec3 fragdir = get_fragdir(texcoord);
	vec3 sky_color = get_sky_color(campos, fragdir);

	vec4 terrain_data = texture2D(terrain_normal_depth, texcoord);
	vec3 terrain_normal = terrain_data.xyz;
	float terrain_ray_dist = terrain_data.w;
	vec3 terrain_pos = campos + fragdir * terrain_ray_dist;

	if (campos.y <= get_water_height(campos.xz, num_waves_surface, 0.0))
	{
		is_underwater = true;
	}

	float ray_dist;

	if (!is_underwater)
	{
		if (terrain_pos.y > sea_level) discard;
		if (!raymarch_water(campos, fragdir, render_distance, ray_dist)) discard;
	}
	else
	{
		if (terrain_pos.y < sea_level - sea_wave_height) discard;
		if (!raymarch_water_underwater(campos, fragdir, render_distance, ray_dist)) discard;
	}

	vec3 hitpos = campos + fragdir * ray_dist;
	gl_FragDepth = get_z(fragdir, ray_dist);
	out_normal_dist = vec4(get_water_normal(hitpos, 0.1, num_waves_normal, 0.0), ray_dist);
	out_diffuse = vec4(1.0);
	out_specular = vec4(1.0, 1.0, 1.0, 10.0);
	out_emissive = vec4(0.0);
	out_scatter = vec4(sky_color, min(ray_dist / render_distance, 1.0));
}
