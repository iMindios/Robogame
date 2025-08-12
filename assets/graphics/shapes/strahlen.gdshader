shader_type canvas_item;
render_mode unshaded, blend_mix;

// ---------------------------
// 1) Parameter für den "Smear"-Effekt
// ---------------------------
uniform float smear_strength : hint_range(0.0, 1.0) = 0.7;  // Wie stark wird der Blur/Effekt ins Bild gemischt
uniform float smear_length : hint_range(0.0, 0.5) = 0.15;   // Maximale Versetzung in UV-Einheiten
uniform float smear_speed  : hint_range(0.0, 10.0) = 2.0;   // Schnelligkeit der oszillierenden Verschiebung
uniform int sample_count   : hint_range(2, 32) = 16;        // Anzahl der Samples
uniform float oscillation_amplitude : hint_range(0.0, 0.1) = 0.02; // Zusätzliche zeitbasierte oszillierende Verschiebung

// ---------------------------
// 2) Parameter für den "Rays"-Effekt
// ---------------------------
uniform vec4 ray_color = vec4(1.0, 1.0, 0.0, 1.0); // Farbe der Rays
uniform float ray_count : hint_range(1.0, 50.0) = 12.0;         // Anzahl der Strahlen (Zacken)
uniform float ray_amplitude : hint_range(0.0, 0.5) = 0.1;       // Modulation der Strahlenlänge
uniform float ray_speed  : hint_range(0.0, 10.0) = 1.0;         // Geschwindigkeit der Ray-Animation
uniform float ray_glow_start : hint_range(0.0, 1.0) = 0.5;      // Ab welchem radialen Abstand beginnen die Rays
uniform float ray_glow_end   : hint_range(0.0, 2.0) = 0.9;      // Ab welchem Abstand verflacht der Effekt

// ---------------------------
// 3) Kombinierter Shader-Code
// ---------------------------
void fragment() {
    // Annahme: Der Sprite ist zentriert bei (0.5, 0.5)
    vec2 center = vec2(0.5, 0.5);
    vec2 diff = UV - center;
    float dist = length(diff);
    vec2 dir = (dist > 0.001) ? normalize(diff) : vec2(0.0, 0.0);

    // --- Smear-Effekt: Mehrfach-Sampling entlang der radials verlaufenden Richtung ---
    vec4 smearAccum = vec4(0.0);
    float weightSum = 0.0;
    for (int i = 0; i < sample_count; i++) {
        float t = float(i) / float(sample_count - 1);
        // Zusätzliches zeitabhängiges Schwanken (Oszillation) für dynamische Bewegung:
        float oscillation = sin(TIME * smear_speed + t * 6.2831853) * oscillation_amplitude;
        vec2 sampleUV = UV + dir * (smear_length * t + oscillation);
        // Gewichtung: Pixel nahe dem Original zählen stärker
        float weight = pow(1.0 - t, 2.0);
        smearAccum += texture(TEXTURE, sampleUV) * weight;
        weightSum += weight;
    }
    vec4 smearColor = smearAccum / weightSum;
    vec4 baseColor = texture(TEXTURE, UV);
    // Mix des Originals mit dem Smear-Effekt
    vec4 finalSmear = mix(baseColor, smearColor, smear_strength);

    // --- Rays-Effekt: Erzeuge dynamisch modulierte Lichtstrahlen ---
    float angle = atan(diff.y, diff.x);
    if (angle < 0.0) {
        angle += 6.2831853;  // Sicherstellen, dass der Winkel im Bereich [0, 2π] liegt
    }
    // Sinus-Oszillation, die pro Winkel den "Strahlen"-Effekt moduliert
    float rayWave = sin(ray_count * angle + TIME * ray_speed) * ray_amplitude;
    // Abhängig vom radialen Abstand wird der Effekt nur im Bereich der Sprite-Ränder sichtbar
    float rayFade = 1.0 - smoothstep(ray_glow_start, ray_glow_end, dist);
    vec4 rayEffect = vec4(ray_color.rgb, 1.0) * rayWave * rayFade;

    // --- Finale Mischung: Beide Effekte additiv kombinieren ---
    // Hier additiv, sodass die Lichtstrahlen den veränderten Sprite "ausstrahlen"
    vec4 combined = finalSmear + rayEffect;
    // Alpha des Originals (oder finalSmear) beibehalten
    combined.a = baseColor.a;

    COLOR = combined;
}
