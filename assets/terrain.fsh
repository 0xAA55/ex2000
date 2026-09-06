#version 330

uniform sampler2D terrain_altmap;
uniform sampler2D terrain_conemap;
uniform float terrain_height;
uniform float terrain_scaling;

vec4 smooth_sample(sampler2D s, vec2 uv);
float get_z(vec3 ray, float dist);
vec3 get_fragdir(vec2 uv);

bool raymarch_terrain(vec3 start, vec3 dir, float max_dist, out float dist)
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
		float height = smooth_sample(terrain_altmap, pos_uv).r * terrain_height;
		if (pos.y - 0.01 <= height) return true;
		float cone = smooth_sample(terrain_conemap, pos_uv).r * cone_mult;
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
