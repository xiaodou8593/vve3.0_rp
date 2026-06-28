#version 330

uniform sampler2D MainSampler;
uniform sampler2D DataSampler;
uniform sampler2D BlurSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

#moj_import <minecraft:globals.glsl>

#moj_import <shader_selector:marker_settings.glsl>
#moj_import <shader_selector:utils.glsl>
#moj_import <shader_selector:data_reader.glsl>

in vec2 texCoord;

out vec4 fragColor;

void main() {
    float roll = readChannel(VVE_ROLL_ANGLE_CHANNEL);
    float angle = radians(roll * 360.0);

    vec2 uv = (texCoord - 0.5) * OutSize;
    uv *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    uv = uv / OutSize + 0.5;

    fragColor = texture(MainSampler, uv);
    if (uv.x < 0. || uv.x > 1. || uv.y < 0. || uv.y > 1.) {
        fragColor = texture(BlurSampler, (uv - 0.5) * sqrt(0.5) + 0.5);
    }
}
