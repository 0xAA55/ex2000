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
uniform vec3 sunpos = normalize(vec3(1.0, 1.0, 1.0));
uniform float sunsize = 1000.0;
uniform float cloud_size_mod = 5.0;
uniform float cloud_height = 1000.0;
uniform float terrain_height = 200.0;
uniform float terrain_scaling = 1000.0;
uniform float fog_distance = 3000.0;
uniform float cloud_border = 0.2;
in vec2 texcoord;
out vec4 color;

vec4 ambcolor = vec4(fogcolor.xyz * 0.5, 1.0);
float cloud_size = cloud_size_mod * cloud_height;
float cloud_fadeout_dist = cloud_size * 5.0;
vec2 cloud_movement = vec2(time * 0.005);

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

void main()
{
	vec4 ndc = vec4(texcoord * 2.0 - 1.0, 1.0, 1.0);
	vec4 camdir_z = inverse(proj) * ndc;
	vec3 fragdir = normalize(mat3(camorient) * camdir_z.xyz);
	mat3 view_rot_inv = inverse(mat3(camorient));

	gl_FragDepth = 1.0;

	vec2 see_cloud = raycast_cloud(campos, fragdir);
	float cloud_in_eye = see_cloud.x;
	float cloud_dist = see_cloud.y;
	cloud_in_eye *= 1.0 - min(1.0, cloud_dist / cloud_fadeout_dist);
	if (cloud_dist <= 0.0) cloud_in_eye = 0.0;

	vec2 raymarch = raymarch_terrain(campos, fragdir, fog_distance);
	if (raymarch.y >= 0.5)
	{
		float dist = raymarch.x;
		vec3 pos_rel_cam = fragdir * dist;
		vec3 zdir = view_rot_inv * pos_rel_cam;
		vec4 clip = proj * vec4(zdir, 1.0);
		float ndc_z = clip.z / clip.w;
		gl_FragDepth = ndc_z * 0.5 + 0.5;
		cloud_in_eye = 0.0;

		vec3 terrain_hit_pos = campos + pos_rel_cam;
		float cloud_shade = get_cloud_shade(terrain_hit_pos);
		vec3 normal = terrain_normal(terrain_hit_pos, 1.0);
		float light = max(0.0, dot(sunpos, normal)) * mix(0.5, 1.0, cloud_shade);
		vec3 diffuse = suncolor.xyz;
		vec3 objcolor = mix(ambcolor.xyz, diffuse.xyz, light);
		color = mix(vec4(objcolor, 1.0), fogcolor, min(dist / fog_distance, 1.0));
	}
	else
	{
		color = mix(fogcolor, skycolor, fragdir.y);
		float sun_occl = get_cloud_shade(campos);
		color = mix(color, vec4(1.0), cloud_in_eye);
		vec4 sun = suncolor * pow(max(dot(fragdir, sunpos), 0.0), sunsize) * (1.0 - sun_occl);
		color += sun;
	}

	color = min(color, vec4(1.0));
}
