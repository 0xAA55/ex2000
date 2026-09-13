#version 330

uniform vec3 sunpos;
uniform sampler2D terrain_altmap;
uniform sampler2D terrain_conemap;
uniform float terrain_height;
uniform float terrain_scaling;

vec3 get_sky_color(vec3 pos, vec3 ray);
vec3 do_sun_blinn_lighting(vec3 eyedir, vec3 position, vec3 normal, vec3 diffuse, vec4 specular);

vec4 rough_sample(sampler2D s, vec2 uv);
vec4 smooth_sample(sampler2D s, vec2 uv);

float get_z(vec3 ray, float dist);
vec3 get_fragdir(vec2 uv);

float get_terrain_height(vec2 pos, bool rough)
{
	vec2 pos_uv = pos / terrain_scaling;
	return (rough ?
		rough_sample(terrain_altmap, pos_uv).r :
		smooth_sample(terrain_altmap, pos_uv).r
	) * terrain_height;
}

bool raymarch_terrain_base(vec3 start, vec3 dir, float max_dist, out float dist, bool rough)
{
	dist = 0.0;
	if (start.y > terrain_height)
	{
		dist = (start.y - terrain_height) / -dir.y;
		if (dir.y > 0.0)
		{
			dist = max_dist;
			return false;
		}
	}
	float cone_mult = length(dir.xz) * terrain_height / terrain_scaling;
	for(int i = 0; i < 64; i++)
	{
		vec3 pos = start + dir * dist;
		vec2 pos_uv = pos.xz / terrain_scaling;
		float height = (rough ?
			rough_sample(terrain_altmap, pos_uv).r :
			smooth_sample(terrain_altmap, pos_uv).r
		) * terrain_height;
		if (pos.y - 0.01 <= height) return true;
		float cone = (rough ?
			rough_sample(terrain_conemap, pos_uv).r :
			smooth_sample(terrain_conemap, pos_uv).r
		) * cone_mult;
		if (cone <= dir.y)
		{
			dist = max_dist;
			return false;
		}
		float step = (pos.y - height) / (cone - dir.y);
		dist += step;
		if (dist >= max_dist) return false;
	}
	return true;
}

bool raymarch_terrain(vec3 start, vec3 dir, float max_dist, out float dist)
{
	return raymarch_terrain_base(start, dir, max_dist, dist, true);
}

bool raymarch_terrain_rough(vec3 start, vec3 dir, float max_dist, out float dist)
{
	return raymarch_terrain_base(start, dir, max_dist, dist, false);
}

vec3 get_terrain_normal(vec3 pos, float e)
{
	vec2 ex = vec2(e / terrain_scaling, 0);
	vec2 tpos = pos.xz / terrain_scaling;
	return normalize(
		vec3(
			smooth_sample(terrain_altmap, tpos - ex.xy).r - smooth_sample(terrain_altmap, tpos + ex.xy).r,
			e / terrain_height,
			smooth_sample(terrain_altmap, tpos - ex.yx).r - smooth_sample(terrain_altmap, tpos + ex.yx).r
		)
	);
}

vec3 get_terrain_basecolor(vec3 pos)
{
	return vec3(1.0);
}

vec4 get_terrain_specular(vec3 pos)
{
	return vec4(1.0, 1.0, 1.0, 100.0);
}

vec3 do_terrain_sun_lighting(vec3 eyedir, vec3 position)
{
	return do_sun_blinn_lighting(eyedir, position,
		get_terrain_normal(position, 1.0),
		get_terrain_basecolor(position),
		get_terrain_specular(position));
}

vec3 get_raymarch_terrain_color_rough(vec3 start, vec3 dir, float max_dist, bool do_fog)
{
	float ray_dist;
	vec3 ret = get_sky_color(start, dir);
	if(raymarch_terrain_rough(start, dir, max_dist, ray_dist))
	{
		vec3 ground_pos = start + dir * ray_dist;
		vec3 terrain_light = do_terrain_sun_lighting(dir, ground_pos);
		if (do_fog)
			ret = mix(terrain_light, ret, min(1.0, ray_dist / max_dist));
		else
			ret = terrain_light;
	}
	return ret;
}
