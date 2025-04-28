shader_type sky;

uniform int vertical_sections = 21;
uniform float star_size = 0.02;
uniform float star_falloff = 4.;
uniform float margin = 0.05;
uniform float warp_intensity = 0.03; // Степень хаотичности звёзд

vec2 get_partition(vec2 sky_coords) {
	float y = sky_coords.y * 2. - 1.;
	float section_y = ceil(abs(y) * float(vertical_sections)) / float(vertical_sections);
	float horizontal_sections = max(4., ceil(float(vertical_sections) * 4. * cos(section_y * PI / 2.)));
	horizontal_sections = max(horizontal_sections, 1.);
	return vec2(sky_coords.x * horizontal_sections, y * float(vertical_sections));
}

vec2 rand_vec2(vec2 xy) {
	float rand1 = fract(sin(dot(xy, vec2(11.9131, 81.2317))) * 57183.77193);
	float rand2 = fract(sin(dot(xy, vec2(16.8131, 91.2327))) * 37113.66193);
	return vec2(rand1, rand2) * (1. - margin * 2.) + margin;
}

float star_brightness(vec2 sky_coords) {
	vec2 partitions = get_partition(sky_coords);
	vec2 partition_index = floor(partitions);
	vec2 inner_coord = fract(partitions);

	// Лёгкое случайное смещение (эффект "дрожащих" звёзд без использования TIME)
	vec2 star_coord = rand_vec2(partition_index) + warp_intensity * sin(partition_index);

	float dist = length(inner_coord - star_coord);
	return pow(star_size / dist, star_falloff);
}

void sky() {
	float brightness = star_brightness(SKY_COORDS);
	vec3 weird_color = vec3(
		fract(SKY_COORDS.x * 3.14),
		fract(SKY_COORDS.y * 2.71),
		fract(SKY_COORDS.x * SKY_COORDS.y * 7.89)
	);
	COLOR = brightness * weird_color;
}
