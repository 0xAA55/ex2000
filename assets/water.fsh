#version 330

const float PI = 3.1415926535897932384626433832795;
const int num_waves_surface = 12;
const int num_waves_normal = num_waves_surface * 2;
const int num_waves_caustic = num_waves_normal;
const float water_refraction = 1.4;
const float water_ETA = 1.0 / water_refraction;

const float lowq_preci = 0.5;

uniform float time;

uniform sampler2D terrain_altmap;
uniform sampler2D terrain_conemap;
uniform float terrain_height;
uniform float terrain_scaling;

uniform float sea_level;
uniform float sea_wave_height;
uniform float sea_wave_size;
uniform vec3 water_scatter_color;
uniform vec3 water_amb_color;
uniform vec3 water_fog_color;
uniform float water_fog_density;

uniform vec3 sunpos;
uniform float sun_brightness;
uniform vec3 suncolor;

uniform int texture_quality;

vec4 smooth_sample(sampler2D s, vec2 uv);

bool raymarch_terrain(vec3 start, vec3 dir, float max_dist, out float dist);
bool raymarch_terrain_rough(vec3 start, vec3 dir, float max_dist, out float dist);
float get_terrain_height(vec2 pos, bool rough);
vec3 get_terrain_normal(vec3 pos, float e);
vec3 get_terrain_basecolor(vec3 pos);
vec4 get_terrain_specular(vec3 pos);

vec3 do_blinn_lighting(vec3 eyedir, vec3 position, vec3 normal, vec3 diffuse, vec4 specular, vec3 light_dir, vec3 ambient_color, vec3 light_color);

float get_water_height(vec2 pos, int num_waves, float phase_shift)
{
	float iter = 0.0;
	float frequency = 1.0 / sea_wave_size;
	float time_mod = 2.0;
	float weight = 1.0;
	float sum_of_values = 0.0;
	float sum_of_weights = 0.0;
	float drag_mult = 0.2;
	float depth_effect_shore = 5.0;
	float depth_effect_offshore = 2.0;
	float cur_terrain_height = smooth_sample(terrain_altmap, pos / terrain_scaling).r * terrain_height;
	float shore_wave_x = max(0.0, sea_level - cur_terrain_height);
	float shore_wave_weight = pow(0.5, shore_wave_x / depth_effect_shore);
	float offshore_wave_weight = 1.0 - pow(0.5, shore_wave_x / depth_effect_offshore);
	float shore_x = phase_shift * frequency + time * time_mod + shore_wave_x;
	float shore_wave = (1.0 - exp(sin(shore_x) - 1.0));
	if (texture_quality <= 0)
	{
		num_waves >>= 1;
		if (num_waves == 0) num_waves = 1;
	}
	float shore_level = -shore_wave;
	for(int i = 0; i < num_waves; i++)
	{
		vec2 p = vec2(sin(iter), cos(iter));
		float wave_x = (dot(p, pos) + phase_shift) * frequency + time * time_mod;
		float wave = 1.0 - exp(sin(wave_x) - 1.0);
		float wave_dx = -wave * cos(wave_x);
		if (texture_quality <= 0)
		{
			wave = floor(wave / lowq_preci) * lowq_preci;
			wave_dx = floor(wave_dx / lowq_preci) * lowq_preci;
		}
		sum_of_values += wave * weight;
		sum_of_weights += weight;
		pos += p * wave_dx * weight * drag_mult;
		weight *= 0.8;
		frequency *= 1.17;
		time_mod *= 1.08;
		iter += 1.399;
	}
	float wave_level = -abs(sum_of_values / sum_of_weights);
	return sea_level + (wave_level * offshore_wave_weight + shore_level * shore_wave_weight) * sea_wave_height;
}

bool raymarch_water(vec3 start, vec3 dir, float max_dist, out float dist)
{
	if (start.y > sea_level && dir.y > 0.0)
	{
		dist = max_dist;
		return false;
	}
	if (start.y >= sea_level) dist = (start.y - sea_level) / -dir.y;
	bool is_hit = false;
	for(int i = 0; i < 64; i++)
	{
		vec3 pos = start + dir * dist;
		float height = get_water_height(pos.xz, num_waves_surface, 0.0);
		if (height + 0.01 >= pos.y) return true;
		dist += pos.y - height;
		if (dist >= max_dist) return false;
	}
	if (dir.y <= 0.0) is_hit = true;
	if (!is_hit) dist = max_dist;
	return is_hit;
}

bool raymarch_water_underwater(vec3 start, vec3 dir, float max_dist, out float dist)
{
	float wave_btm = sea_level - sea_wave_height;
	if (start.y > sea_level)
	{
		dist = max_dist;
		return false;
	}
	if (start.y < wave_btm)
	{
		if (dir.y < 0)
		{
			dist = max_dist;
			return false;
		}
		vec3 btm_pos = start + dir * ((start.y - wave_btm) / dir.y);
		dist = distance(start, btm_pos);
	}
	bool is_hit = false;
	for(int i = 0; i < 64; i++)
	{
		vec3 pos = start + dir * dist;
		float height = get_water_height(pos.xz, num_waves_surface, 0.0);
		if (pos.y + 0.01 >= height) return true;
		dist += height - pos.y;
		if (dist >= max_dist) return false;
	}
	if (dir.y <= 0.0 || dist < max_dist) is_hit = true;
	if (!is_hit) dist = max_dist;
	return is_hit;
}

vec3 get_water_normal(vec3 pos, float e, int num_waves, float phase_shift)
{
	vec2 ex = vec2(e, 0);
	float H = get_water_height(pos.xz, num_waves, phase_shift);
	vec3 a = vec3(pos.x, H, pos.z);
	return normalize(
		cross(
			a - vec3(pos.x - e, get_water_height(pos.xz - ex.xy, num_waves, phase_shift), pos.z),
			a - vec3(pos.x, get_water_height(pos.xz + ex.yx, num_waves, phase_shift), pos.z + e)
		)
	);
}

vec3 scatter_light_in_water(vec3 light, float dist)
{
	float water_fog_thickness = min(1.0, dist * water_fog_density);
	return mix(light * pow(water_scatter_color, vec3(dist)), water_fog_color, water_fog_thickness);
}

float laplacian_depth(vec2 pos, float depth, float eps)
{
	float depth_phase = depth * PI;

	float h0 = get_water_height(pos, num_waves_caustic, depth_phase);

	float hx1 = get_water_height(pos + vec2( eps, 0.0), num_waves_caustic, depth_phase);
	float hx2 = get_water_height(pos + vec2(-eps, 0.0), num_waves_caustic, depth_phase);
	float hz1 = get_water_height(pos + vec2(0.0,  eps), num_waves_caustic, depth_phase);
	float hz2 = get_water_height(pos + vec2(0.0, -eps), num_waves_caustic, depth_phase);

	return (hx1 + hx2 + hz1 + hz2 - 4.0 * h0) / (eps * eps);
}

float caustic_intensity(vec2 pos, float depth)
{
	float depth_mod = depth * abs(1.0 - water_ETA);
	float lap = (laplacian_depth(pos, depth_mod, sea_wave_size));
	float exponent = -lap;
	return exp(exponent);
}

vec3 do_terrain_underwater_lighting(vec3 eyedir, vec3 position)
{
	float water_depth = get_water_height(position.xz, num_waves_surface, 0) - position.y;
	float caustic = caustic_intensity(position.xz, water_depth);
	vec3 lightdir = refract(-sunpos, vec3(0.0, 1.0, 0.0), water_ETA);
	return do_blinn_lighting(eyedir, position,
		get_terrain_normal(position, 1.0),
		get_terrain_basecolor(position),
		get_terrain_specular(position),
		lightdir, water_amb_color * sun_brightness * caustic, suncolor * sun_brightness * caustic);
}

vec3 get_raymarch_underwater_terrain_color_rough(vec3 start, vec3 dir, float max_dist, bool do_scatter)
{
	float ray_dist;
	raymarch_terrain_rough(start, dir, max_dist, ray_dist);
	vec3 ground_pos = start + dir * ray_dist;
	vec3 terrain_light = do_terrain_underwater_lighting(dir, ground_pos);
	if (do_scatter) terrain_light = scatter_light_in_water(terrain_light, ray_dist);
	return terrain_light;
}
