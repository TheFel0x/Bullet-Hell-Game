shader_type canvas_item;

uniform sampler2D screen_mask;

float square(in vec2 p, in float s) {
    vec2 d = abs(p) - s;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.);
}

void fragment() {
	// Set rainbow
	float alpha = 0.5;
	vec3 rgb = vec3(UV, 1);
	COLOR = vec4(rgb, alpha);
	
	// Set Shapes
  vec2 iResolution = (1.0 / SCREEN_PIXEL_SIZE);
  vec2 uv = (FRAGCOORD.xy * 2.0 - iResolution.xy) / iResolution.y;
  vec2 uv0 = uv;
  uv *= 0.75;
  vec3 col = vec3(0);

  for (float i = 1.; i < 4.; i++) {
    uv = fract(uv * 2.) - 0.5;

    float d = square(uv, 1.);
    d *= length(uv0); // to see the squares, comment this line
    d = cos(d * 8. - TIME * i * 0.3);
    d = abs(d);

    // Use TIME to change the color over time
    vec3 colorChange = vec3(sin(TIME * i * 0.5), cos(TIME * i * 0.7), sin(TIME * i * 0.9));
    col += smoothstep(1. / iResolution.y, 0., d - 0.2) * colorChange;
  }

  	COLOR = vec4(col, 0.1);

	// Apply alpha mask
	float opacity = 0.3;
	vec2 muv = UV;
	muv.y = 1.0 - muv.y;
	COLOR.a = texture(screen_mask, muv).r - opacity;
}
