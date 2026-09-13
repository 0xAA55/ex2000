
uniform vec3 sunpos;
uniform float time;
uniform sampler2D cloud_texture;
uniform float cloud_height;
uniform float cloud_size;
uniform float sun_glow_exponent;
uniform float sun_center_brightness;
uniform float sun_brightness;
uniform float sky_brightness;
uniform float fog_density;
uniform vec3 suncolor;
uniform vec3 fogcolor;
uniform vec3 skycolor;
uniform vec3 ambcolor;

vec2 cloud_movement = vec2(time * 0.005);
float cloud_world_size = cloud_size * cloud_height;
float cloud_fadeout_dist = cloud_size * 5.0;

vec2 raycast_cloud(vec3 pos, vec3 dir)
{
	float cloud_dist = (cloud_height - pos.y) / dir.y;
	vec2 cloud_uv = (pos.xz + dir.xz * cloud_dist) / cloud_world_size;
	return vec2(texture2D(cloud_texture, cloud_uv + cloud_movement).r, cloud_dist);
}

float get_cloud_shade(vec3 pos)
{
	if (pos.y >= cloud_height) return 0.0;
	return raycast_cloud(pos, sunpos).x;
}

vec3 get_fog_color()
{
	return fogcolor * sky_brightness;
}

vec3 get_sky_color(vec3 pos, vec3 ray)
{
	vec2 see_cloud = raycast_cloud(pos, ray);
	float cloud_in_eye = see_cloud.x;
	float cloud_dist = see_cloud.y;
	cloud_in_eye *= 1.0 - min(1.0, cloud_dist / cloud_fadeout_dist);
	if (cloud_dist <= 0.0) cloud_in_eye = 0.0;
	vec3 ret = mix(fogcolor, skycolor, ray.y) * sky_brightness;
	ret = mix(ret, vec3(1.0), cloud_in_eye);
	float sun_occl = get_cloud_shade(pos);
	vec3 sun = suncolor * pow(max(dot(ray, sunpos), 0.0), sun_glow_exponent) * sun_center_brightness * (1.0 - sun_occl);
	ret += sun;
	return ret;
}

vec3 do_blinn_lighting(vec3 eyedir, vec3 position, vec3 normal, vec3 diffuse, vec4 specular, vec3 light_dir, vec3 ambient_color, vec3 light_color)
{
	float N_dot_L = max(0.0, dot(normal, -light_dir));
	vec3 halfway = normalize(-(light_dir + eyedir));
	float N_dot_H = max(0.0, dot(normal, halfway));
	vec3 diffuse_lit = mix(
		diffuse * ambient_color,
		diffuse * light_color,
		N_dot_L);
	vec3 specular_lit = specular.xyz * light_color * pow(N_dot_H, specular.w);
	return diffuse_lit + specular_lit;
}

vec3 do_sun_blinn_lighting(vec3 eyedir, vec3 position, vec3 normal, vec3 diffuse, vec4 specular)
{
	return do_blinn_lighting(eyedir, position, normal, diffuse, specular,
		-sunpos,
		ambcolor * sky_brightness,
		suncolor * sun_brightness);
}
