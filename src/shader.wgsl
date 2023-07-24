@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> @builtin(position) vec4<f32> {
    var pos: vec2<f32>;

    // Define the vertices for two triangles that form a square
    // The vertex order is based on the vertex_index input
    switch (in_vertex_index) {
        case 0u: { pos = vec2<f32>(-1.0, -1.0); } // Bottom left vertex of the first triangle
        case 1u, 4u: { pos = vec2<f32>(1.0, -1.0); } // Bottom right vertex of both triangles
        case 2u, 3u: { pos = vec2<f32>(-1.0, 1.0); } // Top left vertex of both triangles
        case 5u: { pos = vec2<f32>(1.0, 1.0); } // Top right vertex of the second triangle
        default: { pos = vec2<f32>(0.0, 0.0); } // Default case, should not be reached in normal operation
    }

    // Return the position as a 4D vector, with z = 0 and w = 1
    return vec4<f32>(pos, 0.0, 1.0);
}

@fragment
fn fs_main(@builtin(position) in_fragCoord: vec4<f32>) -> @location(0) vec4<f32> {
    let x = in_fragCoord.x;
    let y = in_fragCoord.y;
    return vec4<f32>(x, y, 0.0, 1.0);
}