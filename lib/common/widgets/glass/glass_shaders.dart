/// AGSL shader strings ported from KMP Backdrop library for use with Flutter FragmentProgram.
library;

/// SDF helper functions shared by all shaders.
const _roundedRectSdf = """
float radiusAt(float2 coord, float4 radii) {
    if (coord.x >= 0.0) {
        if (coord.y <= 0.0) return radii.y;
        else return radii.z;
    } else {
        if (coord.y <= 0.0) return radii.x;
        else return radii.w;
    }
}

float sdRoundedRect(float2 coord, float2 halfSize, float radius) {
    float2 cornerCoord = abs(coord) - (halfSize - float2(radius));
    float outside = length(max(cornerCoord, 0.0)) - radius;
    float inside = min(max(cornerCoord.x, cornerCoord.y), 0.0);
    return outside + inside;
}

float2 gradSdRoundedRect(float2 coord, float2 halfSize, float radius) {
    float2 cornerCoord = abs(coord) - (halfSize - float2(radius));
    if (cornerCoord.x >= 0.0 || cornerCoord.y >= 0.0) {
        return sign(coord) * normalize(max(cornerCoord, 0.0));
    } else {
        float gradX = step(cornerCoord.y, cornerCoord.x);
        return sign(coord) * float2(gradX, 1.0 - gradX);
    }
}
""";

/// Rounded rect refraction shader (no chromatic aberration).
const roundedRectRefractionShader = """
#include <flutter/runtime_effect.glsl>

uniform vec2 size;
uniform vec2 offset;
uniform vec4 cornerRadii;
uniform float refractionHeight;
uniform float refractionAmount;
uniform float depthEffect;
uniform sampler2D content;

${_roundedRectSdf}

float circleMap(float x) {
    return 1.0 - sqrt(1.0 - x * x);
}

void main() {
    vec2 coord = FlutterFragCoord().xy;
    vec2 halfSize = size * 0.5;
    vec2 centeredCoord = (coord + offset) - halfSize;
    float radius = radiusAt(coord, cornerRadii);
    
    float sd = sdRoundedRect(centeredCoord, halfSize, radius);
    if (-sd >= refractionHeight) {
        fragColor = texture(content, coord / size);
        return;
    }
    sd = min(sd, 0.0);
    
    float d = circleMap(1.0 - -sd / refractionHeight) * refractionAmount;
    float gradRadius = min(radius * 1.5, min(halfSize.x, halfSize.y));
    vec2 grad = normalize(gradSdRoundedRect(centeredCoord, halfSize, gradRadius) + depthEffect * normalize(centeredCoord));
    
    vec2 refractedCoord = coord + d * grad;
    fragColor = texture(content, refractedCoord / size);
}
""";

/// Rounded rect refraction with chromatic aberration (dispersion).
const roundedRectRefractionWithDispersionShader = """
#include <flutter/runtime_effect.glsl>

uniform vec2 size;
uniform vec2 offset;
uniform vec4 cornerRadii;
uniform float refractionHeight;
uniform float refractionAmount;
uniform float depthEffect;
uniform float chromaticAberration;
uniform sampler2D content;

${_roundedRectSdf}

float circleMap(float x) {
    return 1.0 - sqrt(1.0 - x * x);
}

void main() {
    vec2 coord = FlutterFragCoord().xy;
    vec2 halfSize = size * 0.5;
    vec2 centeredCoord = (coord + offset) - halfSize;
    float radius = radiusAt(coord, cornerRadii);
    
    float sd = sdRoundedRect(centeredCoord, halfSize, radius);
    if (-sd >= refractionHeight) {
        fragColor = texture(content, coord / size);
        return;
    }
    sd = min(sd, 0.0);
    
    float d = circleMap(1.0 - -sd / refractionHeight) * refractionAmount;
    float gradRadius = min(radius * 1.5, min(halfSize.x, halfSize.y));
    vec2 grad = normalize(gradSdRoundedRect(centeredCoord, halfSize, gradRadius) + depthEffect * normalize(centeredCoord));
    
    vec2 refractedCoord = coord + d * grad;
    float dispersionIntensity = chromaticAberration * ((centeredCoord.x * centeredCoord.y) / (halfSize.x * halfSize.y));
    vec2 dispersedCoord = d * grad * dispersionIntensity;
    
    vec4 color = vec4(0.0);
    
    vec4 red = texture(content, (refractedCoord + dispersedCoord) / size);
    color.r += red.r / 3.5;
    color.a += red.a / 7.0;
    
    vec4 orange = texture(content, (refractedCoord + dispersedCoord * (2.0 / 3.0)) / size);
    color.r += orange.r / 3.5;
    color.g += orange.g / 7.0;
    color.a += orange.a / 7.0;
    
    vec4 yellow = texture(content, (refractedCoord + dispersedCoord * (1.0 / 3.0)) / size);
    color.r += yellow.r / 3.5;
    color.g += yellow.g / 3.5;
    color.a += yellow.a / 7.0;
    
    vec4 green = texture(content, refractedCoord / size);
    color.g += green.g / 3.5;
    color.a += green.a / 7.0;
    
    vec4 cyan = texture(content, (refractedCoord - dispersedCoord * (1.0 / 3.0)) / size);
    color.g += cyan.g / 3.5;
    color.b += cyan.b / 3.0;
    color.a += cyan.a / 7.0;
    
    vec4 blue = texture(content, (refractedCoord - dispersedCoord * (2.0 / 3.0)) / size);
    color.b += blue.b / 3.0;
    color.a += blue.a / 7.0;
    
    vec4 purple = texture(content, (refractedCoord - dispersedCoord) / size);
    color.r += purple.r / 7.0;
    color.b += purple.b / 3.0;
    color.a += purple.a / 7.0;
    
    fragColor = color;
}
""";

/// Ambient highlight shader (bottom-left 45° lighting).
const ambientHighlightShader = """
#include <flutter/runtime_effect.glsl>

uniform vec2 size;
uniform vec4 cornerRadii;
uniform float angle;
uniform float falloff;

${_roundedRectSdf}

void main() {
    vec2 coord = FlutterFragCoord().xy;
    vec2 halfSize = size * 0.5;
    vec2 centeredCoord = coord - halfSize;
    float radius = radiusAt(coord, cornerRadii);
    
    float gradRadius = min(radius * 1.5, min(halfSize.x, halfSize.y));
    vec2 grad = gradSdRoundedRect(centeredCoord, halfSize, gradRadius);
    vec2 normal = vec2(cos(angle), sin(angle));
    float d = dot(grad, normal);
    float intensity = pow(abs(d), falloff);
    float t = step(0.0, d);
    fragColor = vec4(t, t, t, 1.0) * intensity;
}
""";

/// Default highlight shader (top-right 45° lighting with color).
const defaultHighlightShader = """
#include <flutter/runtime_effect.glsl>

uniform vec2 size;
uniform vec4 cornerRadii;
uniform vec4 color;
uniform float angle;
uniform float falloff;

${_roundedRectSdf}

void main() {
    vec2 coord = FlutterFragCoord().xy;
    vec2 halfSize = size * 0.5;
    vec2 centeredCoord = coord - halfSize;
    float radius = radiusAt(coord, cornerRadii);
    
    float gradRadius = min(radius * 1.5, min(halfSize.x, halfSize.y));
    vec2 grad = gradSdRoundedRect(centeredCoord, halfSize, gradRadius);
    vec2 normal = vec2(cos(angle), sin(angle));
    float d = dot(grad, normal);
    float intensity = pow(abs(d), falloff);
    fragColor = color * intensity;
}
""";

/// Interactive press highlight shader (radial gradient at touch position).
const interactiveHighlightShader = """
#include <flutter/runtime_effect.glsl>

uniform vec2 size;
uniform vec4 color;
uniform float radius;
uniform vec2 position;

void main() {
    vec2 coord = FlutterFragCoord().xy;
    float dist = distance(coord, position);
    float intensity = smoothstep(radius, radius * 0.5, dist);
    fragColor = color * intensity;
}
""";
