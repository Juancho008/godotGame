shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.2, 1.0); // Amarillo brillante

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Usamos la alpha del sprite pero ignoramos su color
    float alpha = tex.a;

    COLOR = vec4(glow_color.rgb, alpha * 0.8); // Más transparencia si querés
}
