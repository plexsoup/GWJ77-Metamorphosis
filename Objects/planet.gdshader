shader_type spatial;
render_mode unshaded;

uniform vec3 sun_position : source_color;  // Get the sun's position from your game script
uniform vec3 albedo : source_color = vec3(0.5);  // Base color of the object
uniform float ambient_light : hint_range(0.0, 1.0) = 0.2; // Minimum light level
uniform float specular_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float specular_shininess : hint_range(1.0, 128.0) = 32.0;

void fragment() {
    // 1. Calculate the direction to the sun (normalized)
    vec3 light_direction = normalize(sun_position - VERTEX);

    // 2. Get the surface normal (normalized)
    vec3 normal = normalize(NORMAL);

    // 3. Calculate the diffuse light component using the dot product
    float diffuse_light = max(0.0, dot(normal, light_direction));

    // 4. Calculate the specular light
    vec3 view_direction = normalize(-VERTEX);
    vec3 reflection_direction = reflect(-light_direction, normal);
    float specular_light = specular_intensity * pow(max(0.0, dot(view_direction, reflection_direction)), specular_shininess);

    // 5. Combine ambient, diffuse, and specular light
    vec3 final_color = albedo * (ambient_light + diffuse_light) + vec3(specular_light);

    // 6. Set the fragment's color
    ALBEDO = final_color;
}