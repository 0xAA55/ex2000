#version 330

uniform int texture_quality = 3;

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
