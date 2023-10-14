shader_type canvas_item;

uniform sampler2D screen_mask;

void fragment() {
	// Set rainbow
	float alpha = 0.5;
	vec3 rgb = vec3(UV, 0.5);
	COLOR = vec4(rgb, alpha);
	
	// Apply alpha mask
	vec2 muv = UV;
	muv.y = 1.0 - muv.y;
	COLOR.a = 0.5 - texture(screen_mask, muv).r;
	
}
