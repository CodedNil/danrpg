const MAX_MARCHING_STEPS : i32 = 255;
const MIN_DIST : f32 = 0.0;
const MAX_DIST : f32 = 100.0;
const EPSILON : f32 = 0.0001;

// Signed distance function for a sphere centered at the origin with radius 1.0;
fn sphereSDF(samplePoint: vec3<f32>) -> f32 {
    return length(samplePoint) - 1.0;
}

// Signed distance function describing the scene.
fn sceneSDF(samplePoint: vec3<f32>) -> f32 {
    return sphereSDF(samplePoint);
}

// Return the shortest distance from the eyepoint to the scene surface along
// the marching direction.
fn shortestDistanceToSurface(eye: vec3<f32>, marchingDirection: vec3<f32>, start: f32, end: f32) -> f32 {
    var depth: f32 = start;
    for (var i: i32 = 0; i < MAX_MARCHING_STEPS; i = i + 1) {
        let dist: f32 = sceneSDF(eye + depth * marchingDirection);
        if dist < EPSILON {
            return depth;
        }
        depth = depth + dist;
        if depth >= end {
            return end;
        }
    }
    return end;
}

// Return the normalized direction to march in from the eye point for a single pixel.
fn rayDirection(fieldOfView: f32, size: vec2<f32>, fragCoord: vec2<f32>) -> vec3<f32> {
    let xy: vec2<f32> = fragCoord - size / 2.0;
    let z: f32 = size.y / tan(radians(fieldOfView) / 2.0);
    return normalize(vec3<f32>(xy, -z));
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) tex_coords: vec2<f32>,
};

@vertex
fn vs_main(@builtin(vertex_index) index: u32) -> VertexOutput {
    var tri = array<vec2<f32>, 6u>(
        vec2<f32>(-1.0, -1.0),
        vec2<f32>(1.0, -1.0),
        vec2<f32>(-1.0, 1.0),
        vec2<f32>(-1.0, 1.0),
        vec2<f32>(1.0, -1.0),
        vec2<f32>(1.0, 1.0),
    );
    var out: VertexOutput;
    out.position = vec4<f32>(tri[index], 0.0, 1.0);
    out.tex_coords = 0.5 * tri[index] + vec2<f32>(0.5, 0.5);
    return out;
}

struct Uniforms {
    resolution: vec2<f32>,
};
@group(0) @binding(0)
var<uniform> uniforms: Uniforms;

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let eye = vec3<f32>(0.0, 0.0, 5.0);
    let dir = rayDirection(45.0, vec2<f32>(1.0, 1.0), in.tex_coords);
    let dist = shortestDistanceToSurface(eye, dir, MIN_DIST, MAX_DIST);

    if dist > MAX_DIST - EPSILON {
        // Didn't hit anything
        return vec4<f32>(0.0, 0.0, 0.0, 0.0);
    }

    return vec4<f32>(1.0, 0.0, 0.0, 1.0);
}