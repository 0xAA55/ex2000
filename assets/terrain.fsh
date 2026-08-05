#version 330

const float PI = 3.14159265358979;
const int num_waves_surface = 12;
const int num_waves_normal = num_waves_surface * 2 + 2;
const int num_waves_simple = num_waves_surface / 2;
const int num_waves_caustic = num_waves_normal;
const float water_refraction = 1.4;
const float water_ETA = 1.0 / water_refraction;

uniform mat4 camorient;
uniform mat4 proj;
uniform vec3 campos;
uniform float time;
uniform sampler2D cloud;
uniform sampler2D terrain;
uniform sampler2D terrain_conemap;
uniform float sun_size_shrink = 10000.0;
uniform float sun_brightness = 5.0;
uniform float sky_brightness = 20.0;
uniform float sun_staring_brightness = 1000.0;
uniform vec3 fogcolor = vec3(0.8, 0.9, 1.0);
uniform vec3 skycolor = vec3(0.1, 0.2, 0.9);
uniform vec3 suncolor = vec3(1.0, 0.9, 0.8);
uniform vec4 water_specular = vec4(1.0, 1.0, 1.0, 10000.0);
uniform float water_attenuation_density = 0.05;
uniform vec3 water_attenuation_baseval = vec3(0.133991590885, 0.119268072602, 0.118039853847);
uniform vec3 sunpos = normalize(vec3(1.0, 1.0, 1.0));
uniform float cloud_size_mod = 5.0;
uniform float cloud_height = 1000.0;
uniform float terrain_height = 200.0;
uniform float terrain_scaling = 1000.0;
uniform float fog_distance = 3000.0;
uniform float sea_level = 0.6 * 200.0;
uniform float sea_wave_height = 1.0;
uniform float sea_wave_size = 1.0;
in vec2 texcoord;
out vec4 color;

vec3 suncolor_hdr = suncolor * sun_brightness;
vec3 skycolor_hdr = skycolor * sky_brightness;
vec3 fogcolor_hdr = fogcolor * sky_brightness;
float cloud_brightness = sky_brightness;
vec3 water_attenuation = water_attenuation_baseval * water_attenuation_density;
float zdepth_out = 1.0;
vec4 ambcolor = vec4(fogcolor * sun_brightness, 1.0);
float cloud_size = cloud_size_mod * cloud_height;
float cloud_fadeout_dist = cloud_size * 5.0;
vec2 cloud_movement = vec2(time * 0.005);
mat3 view_rot_inv = inverse(mat3(camorient));
vec4 ndc = vec4(texcoord * 2.0 - 1.0, 1.0, 1.0);
vec4 camdir_z = inverse(proj) * ndc;
vec3 fragdir = normalize(mat3(camorient) * camdir_z.xyz);
bool is_underwater = false;

vec2 raymarch_terrain_base(vec3 start, vec3 dir, int num_iter, float max_dist)
{
	if (start.y > terrain_height && dir.y > 0.0) return vec2(max_dist, 0.0);
	float dist = 0.0;
	if (start.y > terrain_height) dist = (start.y - terrain_height) / -dir.y;
	float cone_mult = length(dir.xz) * terrain_height / terrain_scaling;
	for(int i = 0; i < num_iter; i++)
	{
		vec3 pos = start + dir * dist;
		vec2 pos_uv = pos.xz / terrain_scaling;
		float height = texture2D(terrain, pos_uv).r * terrain_height;
		if (pos.y - 0.01 <= height) return vec2(dist, 1.0);
		float cone = texture2D(terrain_conemap, pos_uv).r * cone_mult;
		if (cone <= dir.y) return vec2(max_dist, 0.0);
		float step = (pos.y - height) / (cone - dir.y);
		dist += step;
		if (dist >= max_dist) return vec2(max_dist, 0.0);
	}
	return vec2(dist, 1.0);
}

vec2 raymarch_terrain(vec3 start, vec3 dir, float max_dist)
{
	return raymarch_terrain_base(start, dir, 64, max_dist);
}

vec2 raymarch_terrain_rough(vec3 start, vec3 dir, float max_dist)
{
	return raymarch_terrain_base(start, dir, 16, max_dist);
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
	float drag_mult = 0.2;
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
		frequency *= 1.18;
		time_mod *= 1.08;
		iter += 1.399;
	}
	return sea_level - abs(sum_of_values * sea_wave_height / sum_of_weights);
}

float laplacian_depth(vec2 pos, float depth, float eps)
{
	float depth_phase = depth * PI * 10.0;

	float h0 = get_water_height(pos, num_waves_caustic, depth_phase);

	float hx1 = get_water_height(pos + vec2( eps, 0.0), num_waves_caustic, depth_phase);
	float hx2 = get_water_height(pos + vec2(-eps, 0.0), num_waves_caustic, depth_phase);
	float hz1 = get_water_height(pos + vec2(0.0,  eps), num_waves_caustic, depth_phase);
	float hz2 = get_water_height(pos + vec2(0.0, -eps), num_waves_caustic, depth_phase);

	return (hx1 + hx2 + hz1 + hz2 - 4.0 * h0) / (eps * eps);
}

float caustic_intensity(vec2 pos, float depth)
{
	float depth_mod = depth * abs(1.0 - water_ETA) * water_attenuation_density;
	float lap = (laplacian_depth(pos, depth_mod, sea_wave_size));
	float exponent = -lap;
	return exp(exponent);
}

vec2 raymarch_water(vec3 start, vec3 dir, float max_dist)
{
	if (start.y > sea_level && dir.y > 0.0) return vec2(max_dist, 0.0);
	float dist = 0.0;
	if (start.y >= sea_level) dist = (start.y - sea_level) / -dir.y;
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

vec2 raycast_cloud(vec3 pos, vec3 dir)
{
	float cloud_dist = (cloud_height - pos.y) / dir.y;
	vec2 cloud_uv = (pos.xz + dir.xz * cloud_dist) / cloud_size;
	return vec2(texture2D(cloud, cloud_uv + cloud_movement).r, cloud_dist);
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
	vec3 ret = mix(fogcolor_hdr, skycolor_hdr, ray.y);
	ret = mix(ret, vec3(cloud_brightness), cloud_in_eye);
	float sun_occl = get_cloud_shade(pos);
	vec3 sun = suncolor * pow(max(dot(ray, sunpos), 0.0), sun_size_shrink) * sun_staring_brightness * (1.0 - sun_occl);
	ret += sun;
	return ret;
}

vec3 get_terrain_color_base(vec3 light_mask, vec3 spec_mask, vec3 amb_mask, vec3 r_light_dir, vec3 pos, vec3 dir, float dist)
{
	vec3 diffuse = light_mask; // TODO
	vec3 ambient = diffuse * ambcolor.xyz * amb_mask;
	vec4 specular = vec4(0.0, 0.0, 0.0, 1.0); // TODO
	float cloud_shade = mix(0.5, 1.0, get_cloud_shade(pos));
	vec3 normal = terrain_normal(pos, 1.0);
	vec3 reflection = reflect(dir, normal);
	vec3 half_way = normalize(r_light_dir + reflection);
	float diffuse_lit = max(0.0, dot(r_light_dir, normal));
	float dspecular_lit = pow(max(0.0, dot(half_way, normal)), specular.w);
	vec3 objcolor = mix(ambient, diffuse, diffuse_lit);
	vec3 specolor = specular.xyz * cloud_shade * dspecular_lit;
	return mix(objcolor + specolor, fogcolor_hdr, min(dist / fog_distance, 1.0));
}

vec3 get_terrain_color_dry(vec3 pos, vec3 dir, float dist)
{
	return get_terrain_color_base(suncolor_hdr, suncolor_hdr, vec3(1.0), sunpos, pos, dir, dist);
}

vec3 get_terrain_color_underwater(vec3 pos, vec3 dir, float dist)
{
	float water_surface = get_water_height(pos.xz, num_waves_surface, 0.0);
	float floor_depth = water_surface - pos.y;

	float caustic = caustic_intensity(pos.xz, floor_depth);
	vec3 absorbed_light = exp(-water_attenuation * floor_depth);
	vec3 water_lighting = suncolor_hdr * caustic * absorbed_light;

	vec3 scattered_light = exp(-water_attenuation * dist);
	vec3 floor_color = get_terrain_color_base(water_lighting, vec3(0.0), vec3(0.0), vec3(0.0, 1.0, 0.0), pos, dir, 0.0);
	return floor_color * scattered_light;
}

vec3 sky_terrain_rough_color(vec3 pos, vec3 ray)
{
	vec3 ret = sky_color(pos, ray);
	vec2 rayterrain = raymarch_terrain_rough(pos, ray, fog_distance);
	if (rayterrain.y > 0.5)
	{
		vec3 terrain_hit_pos = pos + ray * rayterrain.x;
		ret = get_terrain_color_dry(terrain_hit_pos, ray, rayterrain.x);
	}
	return ret;
}

vec3 get_water_color_abovewater(vec3 eyepos, vec3 water_pos)
{
	float water_dist = distance(eyepos, water_pos);
	vec3 dir = (water_pos - eyepos) / water_dist;
	float cloud_shade = get_cloud_shade(water_pos);
	vec3 wnormal = water_normal(water_pos, 0.1, num_waves_normal, 0.0);
	vec3 refraction_fragdir = refract(dir, wnormal, water_ETA);
	vec3 refraction_lightdir = -refract(-sunpos, wnormal, water_ETA);
	vec2 rayterrain = raymarch_terrain_rough(water_pos, refraction_fragdir, fog_distance);
	vec3 reflection = reflect(dir, wnormal);
	float fresnel = min(1.0, (0.04 + (1.0 - 0.04) * pow(1.0 - max(0.0, dot(-wnormal, dir)), 5.0)));
	vec3 refl_color = sky_terrain_rough_color(water_pos, reflection);
	vec3 specolor = refl_color;
	if (rayterrain.y > 0.5)
	{
		vec3 seabed_rel_surface = refraction_fragdir * rayterrain.x;
		vec3 terrain_hit_pos = water_pos + seabed_rel_surface;
		vec3 underwater_color = get_terrain_color_underwater(terrain_hit_pos, refraction_fragdir, rayterrain.x);
		vec3 objcolor = mix(underwater_color, specolor, fresnel);
		return mix(objcolor, fogcolor_hdr, min(water_dist / fog_distance, 1.0));
	}
	else
	{
		vec3 objcolor = specolor;
		return mix(objcolor, fogcolor_hdr, min(water_dist / fog_distance, 1.0));
	}
}

float get_z(vec3 ray, float dist)
{
	vec3 zdir = view_rot_inv * (ray * dist);
	vec4 clip = proj * vec4(zdir, 1.0);
	float ndc_z = clip.z / clip.w;
	return ndc_z * 0.5 + 0.5;
}

bool draw_abovewater(vec3 pos, vec3 dir, bool z_check)
{
	vec2 rayterrain = raymarch_terrain(pos, dir, fog_distance);
	vec2 raywater = raymarch_water(pos, dir, fog_distance);
	float dist_min = min(rayterrain.x, raywater.x);
	vec3 hitpos = pos + dir * dist_min;

	if (rayterrain.y < 0.5 && raywater.y < 0.5) return false;

	if (z_check)
	{
		float z = get_z(dir, dist_min);
		if (z > zdepth_out) return false;
		zdepth_out = z;
	}

	if (rayterrain.x <= raywater.x)
	{
		color.xyz = get_terrain_color_dry(hitpos, dir, dist_min);
	}
	else
	{
		color.xyz = get_water_color_abovewater(pos, hitpos);
	}
	return true;
}

bool draw_underwater(vec3 pos, vec3 dir, bool z_check)
{
	vec2 rayterrain = raymarch_terrain(pos, dir, fog_distance);
	vec2 raywater = raymarch_water_underwater(pos, dir, fog_distance);
	float dist_min = min(rayterrain.x, raywater.x);
	vec3 hitpos = pos + dir * dist_min;

	if (rayterrain.y < 0.5 && raywater.y < 0.5) return false;

	if (z_check)
	{
		float z = get_z(dir, dist_min);
		if (z > zdepth_out) return false;
		zdepth_out = z;
	}

	if (rayterrain.x <= raywater.x)
	{
		color.xyz = get_terrain_color_underwater(hitpos, dir, dist_min);
	}
	else
	{
		vec3 wnormal = -water_normal(hitpos, 0.1, num_waves_normal, 0.0);
		vec3 refraction = refract(dir, wnormal, water_refraction);
		if (length(refraction) > 0.001)
		{
			vec3 refr_color = sky_terrain_rough_color(hitpos, refraction);
			vec3 scattered_light = exp(-water_attenuation * dist_min);
			color.xyz = refr_color * scattered_light;
		}
		else
		{
			vec3 reflection = reflect(dir, wnormal);
			rayterrain = raymarch_terrain_rough(hitpos, reflection, fog_distance);
			if (rayterrain.y > 0.5)
			{
				vec3 terrain_pos = hitpos + reflection * rayterrain.x;
				color.xyz = get_terrain_color_underwater(terrain_pos, -reflection, dist_min + rayterrain.x);
			}
			else
			{
				color.xyz = vec3(0.0);
			}
		}
	}

	return true;
}

void main()
{
	vec4 specular = vec4(0.0, 0.0, 0.0, 1.0);

	if (campos.y <= get_water_height(campos.xz, num_waves_surface, 0.0))
	{
		is_underwater = true;
	}
	if (!is_underwater)
	{
		if (!draw_abovewater(campos, fragdir, true))
		{
			color.xyz = sky_color(campos, fragdir);
		}
	}
	else
	{
		draw_underwater(campos, fragdir, true);
	}

	color.w = 1.0;
	gl_FragDepth = zdepth_out;
}
