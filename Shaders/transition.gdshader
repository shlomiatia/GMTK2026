shader_type canvas_item;

uniform sampler2D mask_texture;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform bool invert = false;

void fragment() {
    float value = texture(mask_texture, UV).r;

    if (invert) {
        value = 1.0 - value;
    }

    float alpha = step(value, progress);
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}