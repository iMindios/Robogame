shader_type canvas_item;
render_mode unshaded, blend_add;

uniform vec4 neon_color  = vec4(0.0, 1.0, 0.8, 1.0);
uniform float dodge_strength : hint_range(0.0, 1.0) = 0.5;
uniform vec4 overlay_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float overlay_strength : hint_range(0.0, 1.0) = 0.0;

vec3 color_dodge(vec3 base, vec3 blend) {
    vec3 result = vec3(0.0);
    for (int i = 0; i < 3; i++) {
        if (blend[i] >= 1.0 - 0.0001) {
            result[i] = 1.0;
        } else {
            result[i] = clamp(base[i] / (1.0 - blend[i]), 0.0, 1.0);
        }
    }
    return result;
}

void fragment() {
    // Hole die Basisfarbe – bei weißen Formen sollte dies fast 1.0 ergeben.
    vec4 tex_color = texture(TEXTURE, UV);
    // Berechne den Neon-Dodge-Effekt:
    vec3 dodge_result = color_dodge(tex_color.rgb, neon_color.rgb * dodge_strength);
    // Mische den Dodge-Effekt mit dem Overlay-Farbwert, gesteuert durch overlay_strength:
    vec3 final_color = mix(dodge_result, overlay_color.rgb, overlay_strength);
    COLOR = vec4(final_color, tex_color.a);
}
