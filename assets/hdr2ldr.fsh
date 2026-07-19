#version 330

uniform sampler2D blur_texture;
uniform sampler2D hdr_texture;
uniform vec2 standard_size = vec2(200);
in vec2 texcoord;
out vec4 color;

const int blur_radius = 10;
const float min_attenuation = 2.0;

void main()
{
	vec2 texture_size = textureSize(blur_texture, 0);
	vec2 standard_size_mod = vec2(standard_size.x, standard_size.x * texture_size.y / texture_size.x);
	float avr_brightness = length(textureLod(hdr_texture, vec2(0.5), 10000.0).rgb);
	vec3 color_hdr = texture2D(hdr_texture, texcoord).xyz;
	float color_brightness = length(color_hdr);

	float count = 0.0;
	vec3 sum = vec3(0.0);
	for(int y = -blur_radius; y <= blur_radius; y++)
	{
		float dist_mod = pow(2.0, -abs(float(y)) * min_attenuation / float(blur_radius));
		count += 1.0;
		sum += texture2D(blur_texture, texcoord + vec2(0, y) / standard_size_mod).xyz * dist_mod;
	}
	vec3 bloom = sum / count;
	color.xyz = color_hdr * length(vec3(1.0)) / (avr_brightness * 2.0);
	color.xyz += bloom;
	color.w = 1.0;
}
