#version 330

const int num_waves_surface = 12;
const int num_waves_normal = num_waves_surface * 2;
const int num_waves_caustic = num_waves_normal;
const float lowq_preci = 0.5;

uniform float time;

uniform float sea_level;
uniform float sea_wave_height;
uniform float sea_wave_size;

uniform int texture_quality;

float get_water_height(vec2 pos, int num_waves, float phase_shift)
{
	float iter = 0.0;
	float frequency = 1.0 / sea_wave_size;
	float time_mod = 2.0;
	float weight = 1.0;
	float sum_of_values = 0.0;
	float sum_of_weights = 0.0;
	float drag_mult = 0.2;
	if (texture_quality <= 0)
	{
		num_waves >>= 1;
		if (num_waves == 0) num_waves = 1;
	}
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
	return sea_level -abs(sum_of_values * sea_wave_height / sum_of_weights);
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
