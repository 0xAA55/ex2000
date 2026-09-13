#version 330

uniform mat4 camorient;
uniform mat4 proj;
uniform vec3 campos;
uniform sampler2D normal_distance;
uniform sampler2D diffuse;
uniform sampler2D specular;
uniform sampler2D emissive;
uniform sampler2D scatter;
uniform sampler2D fog;
uniform float render_distance;

uniform vec3 sunpos;
uniform vec3 ambcolor;
uniform vec3 suncolor;
uniform float sun_brightness;
uniform float sky_brightness;

in vec2 texcoord;
out vec4 color;

vec3 ambcolor_hdr = ambcolor * sky_brightness;
vec3 suncolor_hdr = suncolor * sun_brightness;

float get_z(vec3 ray, float dist);
vec3 get_fragdir(vec2 uv);

void main()
{
	vec3 fragdir = get_fragdir(texcoord);

	vec4 ss_nd = texture2D(normal_distance, texcoord);
	vec3 ss_diffuse = texture2D(diffuse, texcoord).xyz;
	vec4 ss_specular = texture2D(specular, texcoord);
	vec3 ss_emissive = texture2D(emissive, texcoord).xyz;
	vec4 ss_fog = texture2D(fog, texcoord);

	vec3 normal = ss_nd.xyz;
	vec3 position = campos + normal * ss_nd.w;
	gl_FragDepth = get_z(fragdir, ss_nd.w);

	vec3 refl = reflect(-sunpos, normal);
	vec3 halfway = normalize(refl - fragdir);

	vec3 diffuse = ss_diffuse * vec3(mix(ambcolor_hdr, suncolor_hdr, max(dot(normal, sunpos), 0.0)));
	vec3 specular = ss_specular.xyz * suncolor_hdr * pow(max(0.0, dot(halfway, normal)), ss_specular.w);
	vec3 surface = diffuse + specular + ss_emissive;
	color = vec4(mix(surface, ss_fog.xyz, ss_fog.w), 1.0);
}
