#version 330

const int num_waves_surface = 12;
const int num_waves_normal = num_waves_surface * 2;
const int num_waves_caustic = num_waves_normal;

const float water_refraction = 1.4;
const float water_ETA = 1.0 / water_refraction;

uniform vec3 campos;

uniform sampler2D terrain_normal_depth;
uniform float render_distance;

uniform float sea_level;
uniform float sea_wave_height;
uniform vec3 water_scatter_color;
uniform vec3 water_fog_color;
uniform float water_fog_density;

uniform float sun_brightness;
uniform float sky_brightness;
uniform float fog_density;
uniform vec3 suncolor;
uniform vec3 fogcolor;
uniform vec3 skycolor;
uniform vec3 ambcolor;

in vec2 texcoord;
out vec4 out_normal_dist;
out vec3 out_diffuse;
out vec4 out_specular;
out vec3 out_emissive;
out vec4 out_fog;

float get_water_height(vec2 pos, int num_waves, float phase_shift);
bool raymarch_water(vec3 start, vec3 dir, float max_dist, out float dist);
bool raymarch_water_underwater(vec3 start, vec3 dir, float max_dist, out float dist);
vec3 get_water_normal(vec3 pos, float e, int num_waves, float phase_shift);
vec3 scatter_light_in_water(vec3 light, float dist);
vec3 do_terrain_underwater_lighting(vec3 eyedir, vec3 position);

bool raymarch_terrain(vec3 start, vec3 dir, float max_dist, out float dist);
bool raymarch_terrain_rough(vec3 start, vec3 dir, float max_dist, out float dist);
float get_terrain_height(vec2 pos, bool rough);
vec3 get_terrain_normal(vec3 pos, float e);
vec3 get_terrain_basecolor(vec3 pos);
vec4 get_terrain_specular(vec3 pos);
vec3 do_terrain_lighting(vec3 eyedir, vec3 position);
vec3 get_raymarch_terrain_color_rough(vec3 start, vec3 dir, float max_dist, bool do_fog);
vec3 get_raymarch_underwater_terrain_color_rough(vec3 start, vec3 dir, float max_dist, bool do_scatter);

vec3 get_fog_color();
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
	vec3 hitpos;
	bool is_terrain;
	vec3 wnormal;

	if (!is_underwater)
	{
		if (terrain_pos.y > sea_level) discard;
		if (!raymarch_water(campos, fragdir, render_distance, ray_dist)) discard;
		hitpos = campos + fragdir * ray_dist;
		wnormal = get_water_normal(hitpos, 0.1, num_waves_normal, 0.0);
		out_normal_dist = vec4(wnormal, ray_dist);
	}
	else
	{
		ray_dist = render_distance;
		if (!raymarch_water_underwater(campos, fragdir, render_distance, ray_dist) || terrain_ray_dist < ray_dist)
		{
			is_terrain = true;
			ray_dist = terrain_ray_dist;
			wnormal = terrain_normal;
			out_normal_dist = terrain_data;
			hitpos = terrain_pos;
		}
		else
		{
			is_terrain = false;
			hitpos = campos + fragdir * ray_dist;
			wnormal = get_water_normal(hitpos, 0.1, num_waves_normal, 0.0);
			out_normal_dist = vec4(wnormal, ray_dist);
		}
	}

	out_diffuse = vec3(0.0);
	out_specular = vec4(out_diffuse, 1.0);
	gl_FragDepth = get_z(fragdir, ray_dist);

	if (!is_underwater)
	{
		float fog_thickness = min(1.0, ray_dist * fog_density);

		float bed_dist;
		vec3 mirror_color = get_raymarch_terrain_color_rough(hitpos, reflect(fragdir, wnormal), render_distance, true);
		float fresnel = min(1.0, (0.04 + (1.0 - 0.04) * pow(1.0 - max(0.0, dot(wnormal, -fragdir)), 5.0)));

		vec3 refraction_dir = refract(fragdir, wnormal, water_ETA);
		raymarch_terrain_rough(hitpos, refraction_dir, render_distance, bed_dist);
		vec3 seabed_pos = hitpos + refraction_dir * bed_dist;

		vec3 bed_color = do_terrain_underwater_lighting(refraction_dir, seabed_pos);
		bed_color = scatter_light_in_water(bed_color, bed_dist);

		out_emissive = bed_color + mirror_color * fresnel;
		out_fog = vec4(get_fog_color(), fog_thickness);
	}
	else
	{
		float water_fog_thickness = min(1.0, ray_dist * water_fog_density);
		out_fog = vec4(water_fog_color, water_fog_thickness);
		if (is_terrain)
		{
			vec3 surface_light = do_terrain_underwater_lighting(fragdir, hitpos);
			out_emissive = scatter_light_in_water(surface_light, ray_dist);
		}
		else
		{
			vec3 refraction_dir = refract(fragdir, -wnormal, water_refraction);
			vec3 reflection_dir = reflect(fragdir, -wnormal);
			vec3 surface_light = (length(refraction_dir) > 0.1) ?
				get_raymarch_terrain_color_rough(hitpos, refraction_dir, render_distance, true) :
				get_raymarch_underwater_terrain_color_rough(hitpos, reflection_dir, render_distance, true);
			out_emissive = scatter_light_in_water(surface_light, ray_dist);
		}
	}
}
