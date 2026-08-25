#version 330

uniform mat4 camorient;
uniform mat4 proj;
uniform vec3 campos;
uniform sampler2D terrain_altmap;
uniform sampler2D terrain_conemap;
uniform float terrain_height = 200.0;
uniform float terrain_scaling = 1000.0;
uniform float render_distance = 3000.0;
in vec2 texcoord;
out vec4 out_normal_dist;
out vec4 out_diffuse;
out vec4 out_specular;
out vec4 out_emissive;
out vec4 out_scatter;

uniform int texture_quality = 3;

mat3 view_rot_inv = inverse(mat3(camorient));

vec4 cubic_weights(float t) {
	float t2 = t * t;
	float t3 = t2 * t;
	vec4 w;
	w.x = -0.5 * t3 +       t2 - 0.5 * t;
	w.y =  1.5 * t3 - 2.5 * t2 + 1.0;
	w.z = -1.5 * t3 + 2.0 * t2 + 0.5 * t;
	w.w =  0.5 * t3 - 0.5 * t2;
	return w;
}

vec4 smooth_sample(sampler2D s, vec2 uv)
{
	ivec2 tsize = textureSize(s, 0);
	ivec2 bm = tsize - ivec2(1);

	vec2 texel_uv = uv * vec2(tsize) - 0.5;
	ivec2 base = ivec2(floor(texel_uv));
	vec2 t = texel_uv - vec2(base);

	if (texture_quality >= 3)
	{
		vec4 wx = cubic_weights(t.x);
		vec4 wy = cubic_weights(t.y);

		ivec2 p0 = (base - ivec2(1)) & bm;
		ivec2 p1 = base & bm;
		ivec2 p2 = (base + ivec2(1)) & bm;
		ivec2 p3 = (base + ivec2(2)) & bm;

		vec4 s00 = texelFetch(s, ivec2(p0.x, p0.y), 0);
		vec4 s10 = texelFetch(s, ivec2(p1.x, p0.y), 0);
		vec4 s20 = texelFetch(s, ivec2(p2.x, p0.y), 0);
		vec4 s30 = texelFetch(s, ivec2(p3.x, p0.y), 0);

		vec4 s01 = texelFetch(s, ivec2(p0.x, p1.y), 0);
		vec4 s11 = texelFetch(s, ivec2(p1.x, p1.y), 0);
		vec4 s21 = texelFetch(s, ivec2(p2.x, p1.y), 0);
		vec4 s31 = texelFetch(s, ivec2(p3.x, p1.y), 0);

		vec4 s02 = texelFetch(s, ivec2(p0.x, p2.y), 0);
		vec4 s12 = texelFetch(s, ivec2(p1.x, p2.y), 0);
		vec4 s22 = texelFetch(s, ivec2(p2.x, p2.y), 0);
		vec4 s32 = texelFetch(s, ivec2(p3.x, p2.y), 0);

		vec4 s03 = texelFetch(s, ivec2(p0.x, p3.y), 0);
		vec4 s13 = texelFetch(s, ivec2(p1.x, p3.y), 0);
		vec4 s23 = texelFetch(s, ivec2(p2.x, p3.y), 0);
		vec4 s33 = texelFetch(s, ivec2(p3.x, p3.y), 0);

		vec4 row0 = wx.x * s00 + wx.y * s10 + wx.z * s20 + wx.w * s30;
		vec4 row1 = wx.x * s01 + wx.y * s11 + wx.z * s21 + wx.w * s31;
		vec4 row2 = wx.x * s02 + wx.y * s12 + wx.z * s22 + wx.w * s32;
		vec4 row3 = wx.x * s03 + wx.y * s13 + wx.z * s23 + wx.w * s33;

		return wy.x * row0 + wy.y * row1 + wy.z * row2 + wy.w * row3;
	}
	else if (texture_quality >= 2)
	{
		vec4 x00 = texelFetch(s, (base + ivec2(0, 0)) & bm, 0);
		vec4 x10 = texelFetch(s, (base + ivec2(1, 0)) & bm, 0);
		vec4 x01 = texelFetch(s, (base + ivec2(0, 1)) & bm, 0);
		vec4 x11 = texelFetch(s, (base + ivec2(1, 1)) & bm, 0);
		t = smoothstep(vec2(0.0), vec2(1.0), t);
		return mix(mix(x00, x10, t.x), mix(x01, x11, t.x), t.y);
	}
	else if (texture_quality >= 1)
	{
		return texture2D(s, uv);
	}
	else
	{
		vec2 texel_uv = uv * vec2(tsize);
		ivec2 base = ivec2(floor(texel_uv));
		return texelFetch(s, base & bm, 0);
	}
}

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

float get_z(vec3 ray, float dist)
{
	vec3 zdir = view_rot_inv * (ray * dist);
	vec4 clip = proj * vec4(zdir, 1.0);
	float ndc_z = clip.z / clip.w;
	return ndc_z * 0.5 + 0.5;
}

void main()
{
	vec4 ndc = vec4(texcoord * 2.0 - 1.0, 1.0, 1.0);
	vec4 camdir_z = inverse(proj) * ndc;
	vec3 fragdir = normalize(mat3(camorient) * camdir_z.xyz);
	float ray_dist;
	if (!raymarch_terrain(campos, fragdir, render_distance, ray_dist)) discard;

	vec3 hitpos = campos + fragdir * ray_dist;
	gl_FragDepth = get_z(fragdir, ray_dist);
	out_normal_dist = vec4(get_terrain_normal(hitpos, 1.0), ray_dist);
	out_diffuse = vec4(1.0);
	out_specular = vec4(1.0, 1.0, 1.0, 10.0);
	out_emissive = vec4(0.0);
	out_scatter = vec4(1.0);
}
