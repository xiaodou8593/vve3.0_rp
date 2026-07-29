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

const float TAU = 6.28318530717958647692;

void main() {
    // --------------------------------------------------
    // FakeFOV
    // --------------------------------------------------

    float fakeFov = clamp(
        readChannel(FAKE_FOV_CHANNEL),
        0.0,
        1.0
    );

    // --------------------------------------------------
    // 读取16位滚转角
    // --------------------------------------------------
    //
    // 高位通道使用循环操作：
    //   marker blue = highByte
    //   output = highByte / 256
    //
    // 低位通道使用非循环操作：
    //   marker blue = lowByte
    //   output = lowByte / 255
    //
    // 不能对正在插值的通道进行round()，否则插值会重新变成离散跳变。
    // --------------------------------------------------

    float highPart = fract(
        readChannel(VVE_ROLL_ANGLE_HIGH_CHANNEL)
    );

    float lowByte = clamp(
        readChannel(VVE_ROLL_ANGLE_LOW_CHANNEL),
        0.0,
        1.0
    ) * 255.0;

    // highPart已经等于highByte/256。
    // lowByte在完整一圈中的权重为lowByte/65536。
    float rotation = fract(
        highPart + lowByte / 65536.0
    );

    // 直接使用数据包中的psi方向，不取反。
    float angle = rotation * TAU;

    // --------------------------------------------------
    // 计算任意滚转角下都不会产生黑边的FakeFOV缩放
    // --------------------------------------------------

    float screenAspect = max(
        OutSize.x / OutSize.y,
        0.0001
    );

    float longAspect = max(
        screenAspect,
        1.0 / screenAspect
    );

    float allRollSafeZoom =
        sqrt(1.0 + longAspect * longAspect) * 1.001;

    // 投影平面上的等比例缩放，不改变横纵比例。
    float zoom = mix(
        1.0,
        allRollSafeZoom,
        fakeFov
    );

    // --------------------------------------------------
    // 旋转屏幕采样坐标
    // --------------------------------------------------

    vec2 pixelCoord =
        ((texCoord - 0.5) / zoom) * OutSize;

    float angleCos = cos(angle);
    float angleSin = sin(angle);

    pixelCoord *= mat2(
         angleCos, -angleSin,
         angleSin,  angleCos
    );

    vec2 uv =
        pixelCoord / OutSize + 0.5;

    // --------------------------------------------------
    // 保留原来的BlurSampler越界处理
    // --------------------------------------------------

    bool inBounds =
        all(greaterThanEqual(uv, vec2(0.0))) &&
        all(lessThanEqual(uv, vec2(1.0)));

    vec3 color;

    if (inBounds) {
        color = texture(
            MainSampler,
            uv
        ).rgb;
    } else {
        vec2 blurUV =
            (uv - 0.5) * sqrt(0.5) + 0.5;

        color = texture(
            BlurSampler,
            clamp(blurUV, vec2(0.0), vec2(1.0))
        ).rgb;
    }

    fragColor = vec4(color, 1.0);
}