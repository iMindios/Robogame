shader_type canvas_item;
render_mode unshaded, blend_add;

// Wie stark soll der Verschmierungseffekt sichtbar sein? (0 = Original, 1 = kompletter Effekt)
uniform float smear_strength : hint_range(0.0, 2.0) = 0.7;
// Maximale Verschiebung in UV-Einheiten, die der Effekt erzeugen soll (größere Werte = ausgeprägtere Strahlen)
uniform float smear_length : hint_range(0.0, 0.5) = 0.041;
// Geschwindigkeit der dynamischen Bewegung (hohe Werte = schneller pulsieren)
uniform float smear_speed  : hint_range(0.0, 10.0) = 2.0;
// Anzahl der Samples, die entlang der Strahlrichtung gemittelt werden (mehr Samples = sanfter, aber rechenintensiver)
uniform int sample_count : hint_range(2, 32) = 29;

void fragment() {
    // Annahme: Sprite ist zentriert; passe center ggf. an, falls nötig.
    vec2 center = vec2(0.5, 0.5);
    vec2 diff = UV - center;
    float dist = length(diff);
    // Vermeide Division durch 0 an der Mitte
    vec2 dir = (dist > 0.001) ? normalize(diff) : vec2(0.0, 0.0);

    // Oszillation, die mit der Zeit und dem Abstand variiert,
    // sodass weiter außen ein stärkerer Effekt zu sehen ist.
    float oscillation = sin(TIME * smear_speed + dist * 20.0);
    // Bestimme den effektiven Versatz entlang der Richtung.
    float offset_magnitude = smear_length * oscillation;

    // Mehrfach-Sampling entlang der Radialrichtung:
    vec4 accumulated = vec4(0.0);
    float weight_sum = 0.0;

    // Jeweils Samples von t = 0 (aktueller Pixel) bis t = 1 (maximaler Versatz)
    for (int i = 0; i < sample_count; i++) {
        float t = float(i) / float(sample_count - 1);
        // Exponentielle Gewichte: Der zentrale Teil zählt stärker
        float weight = pow(1.0 - t, 2.0);
        vec2 sampleUV = UV + dir * offset_magnitude * t;
        accumulated += texture(TEXTURE, sampleUV) * weight;
        weight_sum += weight;
    }

    vec4 smearedColor = accumulated / weight_sum;
    vec4 originalColor = texture(TEXTURE, UV);

    // Mische das Original mit dem verschmierten Effekt.
    COLOR = mix(originalColor, smearedColor, smear_strength);
}
