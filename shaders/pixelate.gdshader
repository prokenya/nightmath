shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int pixel_size : hint_range(1, 64) = 4; // Pixel size

void fragment() {
    // Получаем размеры экрана правильно
    vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0));

    // Вычисляем координаты пикселя в экранных координатах
    vec2 pixel_coords = floor(FRAGCOORD.xy / float(pixel_size)) * float(pixel_size);

    // Конвертируем пиксельные координаты в UV-координаты
    vec2 uv = pixel_coords / screen_size;

    // Получаем цвет из текстуры экрана
    COLOR = texture(SCREEN_TEXTURE, uv);
}
