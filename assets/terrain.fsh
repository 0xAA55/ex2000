#version 330

uniform mat4 camorient;
uniform mat4 proj;
uniform vec3 campos;
uniform float time;
uniform sampler2D cloud;
uniform sampler2D terrain;
uniform vec4 fogcolor = vec4(0.8, 0.9, 1.0, 1.0);
uniform vec4 skycolor = vec4(0.3, 0.4, 0.9, 1.0);
uniform vec4 suncolor = vec4(1.0, 0.9, 0.8, 1.0);
uniform vec4 water_specular = vec4(1.0, 1.0, 1.0, 100.0);
uniform float water_attenuation_density = 0.05;
uniform vec3 water_attenuation_baseval = vec3(0.133991590885, 0.119268072602, 0.118039853847);
uniform vec3 sunpos = normalize(vec3(1.0, 1.0, 1.0));
uniform float sun_size_shrink = 10000.0;
uniform float sun_brightness = 100000.0;
uniform float cloud_size_mod = 5.0;
uniform float cloud_height = 1000.0;
uniform float terrain_height = 200.0;
uniform float terrain_scaling = 1000.0;
uniform float fog_distance = 3000.0;
uniform float cloud_border = 0.2;
uniform float sea_level = 0.6 * 200.0;
uniform float sea_wave_height = 2.0;
uniform float sea_wave_size = 2.0;
in vec2 texcoord;
out vec4 color;

float zdepth_out = 1.0;
vec4 ambcolor = vec4(fogcolor.xyz * 0.5, 1.0);
float cloud_size = cloud_size_mod * cloud_height;
float cloud_fadeout_dist = cloud_size * 5.0;
vec2 cloud_movement = vec2(time * 0.005);
mat3 view_rot_inv = inverse(mat3(camorient));
vec4 ndc = vec4(texcoord * 2.0 - 1.0, 1.0, 1.0);
vec4 camdir_z = inverse(proj) * ndc;
vec3 fragdir = normalize(mat3(camorient) * camdir_z.xyz);
bool is_underwater = false;

vec2 raymarch_terrain(vec3 start, vec3 dir, float max_dist)
{
	if (start.y > terrain_height && dir.y > 0.0) return vec2(max_dist, 0.0);
	vec3 top_pos = start + dir * ((start.y - terrain_height) / dir.y);
	float dist = 0.0;
	if (start.y >= terrain_height) dist = distance(start, top_pos);
	float step_modifier = 2.0;
	float last_dir = 1.0;
	float is_hit = 0.0;
	for(int i = 0; i < 384; i++)
	{
		float step = 1.0 / step_modifier;
		vec3 pos = start + dir * dist;
		float height = texture2D(terrain, pos.xz / terrain_scaling).r * terrain_height;
		if (pos.y < height)
		{
			is_hit = 1.0;
			dist -= (height - pos.y) * step;
			if (dist <= 0.0) return vec2(0.0, 1.0);
			if (step_modifier >= 8.0) return vec2(dist, 1.0);
			if (last_dir >= 0.0)
			{
				last_dir = -1.0;
				step_modifier += 1.0;
			}
		}
		else
		{
			if (height + 0.01 >= pos.y) return vec2(dist, 1.0);
			dist += (pos.y - height) * step;
			if (dist >= max_dist) return vec2(max_dist, 0.0);
			if (last_dir <= 0.0)
			{
				last_dir = 1.0;
				step_modifier += 1.0;
			}
		}
	}
	if (dir.y <= 0.0 || dist < max_dist) is_hit = 1.0;
	if (is_hit < 0.5) dist = max_dist;
	return vec2(dist, is_hit);
}

vec2 raymarch_terrain_rough(vec3 start, vec3 dir, float max_dist)
{
	if (start.y > terrain_height && dir.y > 0.0) return vec2(max_dist, 0.0);
	vec3 top_pos = start + dir * ((start.y - terrain_height) / dir.y);
	float dist = 0.0;
	if (start.y >= terrain_height) dist = distance(start, top_pos);
	float step_modifier = 2.0;
	float last_dir = 1.0;
	float is_hit = 0.0;
	for(int i = 0; i < 64; i++)
	{
		float step = 1.0 / step_modifier;
		vec3 pos = start + dir * dist;
		float height = texture2D(terrain, pos.xz / terrain_scaling).r * terrain_height;
		if (pos.y < height)
		{
			is_hit = 1.0;
			dist -= (height - pos.y) * step;
			if (dist <= 0.0) return vec2(0.0, 1.0);
			if (step_modifier >= 8.0) return vec2(dist, 1.0);
			if (last_dir >= 0.0)
			{
				last_dir = -1.0;
				step_modifier += 1.0;
			}
		}
		else
		{
			if (height + 0.01 >= pos.y) return vec2(dist, 1.0);
			dist += (pos.y - height) * step;
			if (dist >= max_dist) return vec2(max_dist, 0.0);
			if (last_dir <= 0.0)
			{
				last_dir = 1.0;
				step_modifier += 1.0;
			}
		}
	}
	if (dir.y <= 0.0 || dist < max_dist) is_hit = 1.0;
	if (is_hit < 0.5) dist = max_dist;
	return vec2(dist, is_hit);
}

vec3 terrain_normal(vec3 pos, float e)
{
	vec2 ex = vec2(e / terrain_scaling, 0);
	vec2 tpos = pos.xz / terrain_scaling;
	return normalize(
		vec3(
			texture2D(terrain, tpos + ex.xy).r - texture2D(terrain, tpos - ex.xy).r,
			ex.x * terrain_scaling / terrain_height,
			texture2D(terrain, tpos + ex.yx).r - texture2D(terrain, tpos - ex.yx).r
		)
	);
}

float get_water_height(vec2 pos, int num_waves, float phase_shift)
{
	float phase_shift_on_pos = length(pos) * PI * 0.1;
	float iter = 0.0;
	float frequency = 1.0 / sea_wave_size;
	float time_mod = 2.0;
	float weight = 1.0;
	float sum_of_values = 0.0;
	float sum_of_weights = 0.0;
	float drag_mult = 0.1;
	for(int i = 0; i < num_waves; i++)
	{
		vec2 p = vec2(sin(iter), cos(iter));
		float wave_x = dot(p, pos) * frequency + time * time_mod + phase_shift_on_pos + phase_shift * frequency;
		float wave = 1.0 - exp(sin(wave_x) - 1.0);
		float wave_dx = -wave * cos(wave_x);
		sum_of_values += wave * weight;
		sum_of_weights += weight;

		pos += p * wave_dx * weight * drag_mult;

		weight *= 0.8;
		frequency *= 1.28;
		time_mod *= 1.08;
		iter += 1.399;
	}
	return sea_level - abs(sum_of_values * sea_wave_height / sum_of_weights);
}

float laplacian_depth(vec2 pos, float depth, float eps)
{
	float depth_phase = depth;

	float h0 = get_water_height(pos, num_waves_caustic, depth_phase);

	float hx1 = get_water_height(pos + vec2( eps, 0.0), num_waves_caustic, depth_phase);
	float hx2 = get_water_height(pos + vec2(-eps, 0.0), num_waves_caustic, depth_phase);
	float hz1 = get_water_height(pos + vec2(0.0,  eps), num_waves_caustic, depth_phase);
	float hz2 = get_water_height(pos + vec2(0.0, -eps), num_waves_caustic, depth_phase);

	return (hx1 + hx2 + hz1 + hz2 - 4.0 * h0) / (eps * eps);
}

float caustic_intensity(vec2 pos, float depth)
{
	depth *= abs(1.0 - water_ETA) * water_attenuation_density;
	float lap = laplacian_depth(pos, depth, 1.0);
	float C = 2.5;
	float compressed = C * tanh(depth * lap / C);
	return exp(-compressed);

	float scale = depth * (1.0 - water_ETA);
	float exponent = scale * lap;
	return exp(exponent);
}

vec2 raymarch_water(vec3 start, vec3 dir, float max_dist)
{
	if (start.y > sea_level && dir.y > 0.0) return vec2(max_dist, 0.0);
	vec3 top_pos = start + dir * ((start.y - sea_level) / dir.y);
	float dist = 0.0;
	if (start.y >= sea_level) dist = distance(start, top_pos);
	float is_hit = 0.0;
	for(int i = 0; i < 64; i++)
	{
		vec3 pos = start + dir * dist;
		float height = get_water_height(pos.xz, num_waves_surface, 0.0);
		if (height + 0.01 >= pos.y) return vec2(dist, 1.0);
		dist += pos.y - height;
		if (dist >= max_dist) return vec2(max_dist, 0.0);
	}
	if (dir.y <= 0.0) is_hit = 1.0;
	if (is_hit < 0.5) dist = max_dist;
	return vec2(dist, is_hit);
}

vec2 raymarch_water_underwater(vec3 start, vec3 dir, float max_dist)
{
	float dist = 0.0;
	float wave_btm = sea_level - sea_wave_height;
	if (start.y > sea_level) return vec2(max_dist, 0.0);
	if (start.y < wave_btm)
	{
		if (dir.y < 0) return vec2(max_dist, 0.0);
		vec3 btm_pos = start + dir * ((start.y - wave_btm) / dir.y);
		dist = distance(start, btm_pos);
	}
	float is_hit = 0.0;
	for(int i = 0; i < 64; i++)
	{
		vec3 pos = start + dir * dist;
		float height = get_water_height(pos.xz, num_waves_surface, 0.0);
		if (pos.y + 0.01 >= height) return vec2(dist, 1.0);
		dist += height - pos.y;
		if (dist >= max_dist) return vec2(max_dist, 0.0);
	}
	if (dir.y <= 0.0 || dist < max_dist) is_hit = 1.0;
	if (is_hit < 0.5) dist = max_dist;
	return vec2(dist, is_hit);
}

vec3 water_normal(vec3 pos, float e, int num_waves, float phase_shift)
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

float cloud_tadj(float sampled)
{
	float ret = 0.0;
	if (sampled > cloud_border) ret = (sampled - cloud_border) / (1.0 - cloud_border);
	return ret;
}

vec2 raycast_cloud(vec3 pos, vec3 dir)
{
	float cloud_dist = (cloud_height - pos.y) / dir.y;
	vec2 cloud_uv = (pos.xz + dir.xz * cloud_dist) / cloud_size;
	return vec2(cloud_tadj(texture2D(cloud, cloud_uv + cloud_movement).r), cloud_dist);
}

float get_cloud_shade(vec3 pos)
{
	if (pos.y >= cloud_height) return 0.0;
	return raycast_cloud(pos, sunpos).x;
}

vec3 sky_color(vec3 pos, vec3 ray)
{
	vec2 see_cloud = raycast_cloud(pos, ray);
	float cloud_in_eye = see_cloud.x;
	float cloud_dist = see_cloud.y;
	cloud_in_eye *= 1.0 - min(1.0, cloud_dist / cloud_fadeout_dist);
	if (cloud_dist <= 0.0) cloud_in_eye = 0.0;
	vec3 ret = mix(fogcolor.xyz, skycolor.xyz, ray.y);
	ret = mix(ret, vec3(1.0), cloud_in_eye);
	float sun_occl = get_cloud_shade(pos);
	vec3 sun = suncolor.xyz * pow(max(dot(ray, sunpos), 0.0), sun_size_shrink) * sun_brightness * (1.0 - sun_occl);
	ret += sun;
	return ret;
}

vec3 get_terrain_color_base(vec3 light_mask, vec3 spec_mask, vec3 r_light_dir, vec3 pos, vec3 dir, float distance)
{
	vec3 ambient = light_mask * ambcolor.xyz;
	vec3 diffuse = light_mask; // TODO
	vec4 specular = vec4(0.0, 0.0, 0.0, 1.0); // TODO
	float cloud_shade = mix(0.5, 1.0, get_cloud_shade(pos));
	vec3 normal = terrain_normal(pos, 1.0);
	vec3 reflection = reflect(dir, normal);
	vec3 half_way = normalize(r_light_dir + reflection);
	float diffuse_lit = max(0.0, dot(r_light_dir, normal));
	float dspecular_lit = pow(max(0.0, dot(half_way, normal)), specular.w);
	vec3 objcolor = mix(ambient, diffuse.xyz, diffuse_lit);
	vec3 specolor = specular.xyz * cloud_shade * dspecular_lit;
	return mix(objcolor + specolor, fogcolor.xyz, min(distance / fog_distance, 1.0));
}

vec3 get_terrain_color_dry(vec3 pos, vec3 dir, float distance)
{
	return get_terrain_color_base(suncolor.xyz, suncolor.xyz, sunpos, pos, dir, distance);
}

vec3 get_terrain_color_underwater(vec3 pos, vec3 dir, float distance)
{
	float water_surface = get_water_height(pos.xz, num_waves_surface, 0.0);
	float floor_depth = water_surface - pos.y;

	float caustic = caustic_intensity(pos.xz, floor_depth);
	vec3 absorbed_light = exp(-water_attenuation * floor_depth);
	vec3 water_lighting = suncolor.xyz * caustic * absorbed_light;

	vec3 scattered_light = exp(-water_attenuation * distance);
	vec3 floor_color = get_terrain_color_base(water_lighting, vec3(0.0), vec3(0.0, 1.0, 0.0), pos, dir, 0.0);
	return floor_color * scattered_light;
}

