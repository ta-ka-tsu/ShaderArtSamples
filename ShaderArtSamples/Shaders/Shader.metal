//
//  Shader.metal
//  ShaderArtSamples
//
//  Created by TakatsuYouichi on 2019/07/14.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;


fragment float4 Sample2_1(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    return step(length(uv), 1.0);
}

// ダイヤ
fragment float4 Sample2_1_2(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float manhattanDist = abs(uv.x) + abs(uv.y);
    return step(manhattanDist, 1.0);
}

// 四角
fragment float4 Sample2_1_3(float4 pixPos [[position]],
                            constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float chebyshevDist = max(abs(uv.x), abs(uv.y));
    return step(chebyshevDist, 1.0);
}

// 花
fragment float4 Sample2_2(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.5*sin(5 * theta) + 0.5;
    return step(length(uv), threshold);
}

// 星
fragment float4 Sample2_3(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// 回転する星
fragment float4 Sample2_4(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]],
                          constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x) - time;
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// 複製した回転する星
fragment float4 Sample2_5(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]],
                          constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2.0;
    uv = fract(uv) * 2.0 - 1.0;

    float theta = atan2(uv.y, uv.x) - time;
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// もっと複製した回転する星
fragment float4 Sample2_6(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]],
                          constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 5.0;
    uv = fract(uv) * 2.0 - 1.0;
    
    float theta = atan2(uv.y, uv.x) - time;
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// 複製した円
fragment float4 Sample2_7(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2.0;
    uv = fract(uv) * 2.0 - 1.0;

    return step(length(uv), 1.0);
}

// グリッド毎にサイズを変えた円
fragment float4 Sample2_8(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2.0;
    float2 id = floor(uv);
    uv = fract(uv) * 2.0 - 1.0;
    
    float threshold = exp(-length(id));
    return step(length(uv), threshold);
}

// グリッド毎にサイズを変えた円(中心版)
fragment float4 Sample2_9(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv = 2.0 * uv + 0.5;
    float2 id = floor(uv);
    uv = fract(uv) * 2.0 - 1.0;
    
    float threshold = exp(-length(id));
    return step(length(uv), threshold);
}

float2 rot(float2 p, float theta) {
    float c = cos(theta);
    float s = sin(theta);
    float2x2 mat(c, -s, s, c);
    return mat * p;
}

// グリッド毎にサイズを変えた円(中心版)+アニメーション
fragment float4 Sample2_10(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv = rot(uv, time);
    
    uv = 2.0 * uv + 0.5;
    float2 id = floor(uv);
    uv = fract(uv) * 2.0 - 1.0;
    
    float threshold = exp(-(0.5*sin(2.0*time)+0.5)*length(id));
    return step(length(uv), threshold);
}

fragment float4 Noise1(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    return fract(100000*sin(uv.x));
}

fragment float4 Noise2(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    return fract(sin(dot(uv, float2(12.9898,78.233)))*43758.5453123);
}

fragment float4 Noise3(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    return N21(id);
}

fragment float4 Noise4(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]],
                       constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    uv = fract(4*uv)*2.0 - 1.0;
    
    float r = fract(sin(dot(id, float2(12.9898,78.233)))*43758.5453123);

    return step(length(uv), 0.5 + 0.5*sin(3*time + 5*r));
}

// 色付きブロックノイズ(汚い)
fragment float4 Color1(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]],
                       constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float r = N21(id);
    float g = N21(id + float2(123.34, 32.34));
    float b = N21(id + float2(23.0, 342.0));
    return float4(r, g, b, 1.0);
}

// 色付きブロックノイズ(ビビッド)
fragment float4 Color2(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float h = N21(id);
    float3 rgb = hsv2rgb(h, 1.0, 1.0);
    return float4(rgb, 1.0);
}

// 色付きブロックノイズ(おとなしめ)
fragment float4 Color3(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float h = N21(id);
    float3 rgb = hsv2rgb(h, 0.7, 1.0);
    return float4(rgb, 1.0);
}

// 色付き円アニメーション
fragment float4 Color4(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]],
                       constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float h = N21(id);
    float3 rgb = hsv2rgb(fract(h + 0.2*time), 0.7, 1.0);
    return float4(rgb, 1.0);
}

// 色付き円アニメーション
fragment float4 Color5(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]],
                       constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float h = N21(id);
    float3 rgb = hsv2rgb(fract(h + 0.2*time), 0.7, 1.0);
    
    uv = fract(4*uv)*2.0 - 1.0;
    return float4(rgb, 1.0) * step(length(uv), 0.5 + 0.5*sin(3*time + 5*h));
}

// テクスチャ(逆さ)
fragment float4 Texture1(float4 pixPos [[position]],
                         constant float2& res[[buffer(0)]],
                         texture2d<float> tex[[texture(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;

    constexpr sampler s(address::clamp_to_edge, filter::linear);
    return tex.sample(s, uv);
}

// テクスチャ(正方向、クランプ)
fragment float4 Texture2(float4 pixPos [[position]],
                         constant float2& res[[buffer(0)]],
                         texture2d<float> tex[[texture(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    return tex.sample(s, uv);
}

fragment float4 Texture3(float4 pixPos [[position]],
                         constant float2& res[[buffer(0)]],
                         constant float& time[[buffer(1)]],
                         texture2d<float> tex[[texture(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    
    constexpr sampler s(address::repeat, filter::linear);
    
    float2 id = floor(uv);
    float d = N21(id) + time;
    float offset = (sin(3 * d))*pow(sin(7*d), 10.0);
    
    return tex.sample(s, uv + offset);
}


fragment float4 Crystal(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]],
                           texture2d<float> tex[[texture(1)]])
{
    float4 col = 0.0;
    
    // 左上原点
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    
    float distortion = saturate(0.7 - length(uv - float2(0.5* sin(2.5 * time), 0.3 * cos(2.5 * time))));
    float2 offset = -0.9 * sqrt(distortion) * uv;
    
    float2 texUV = pixPos.xy/res;
    constexpr sampler s(address::repeat, filter::linear);
    col = tex.sample(s, texUV + offset);
    
    return col;
}

fragment float4 Sample1_8_Accel(float4 pixPos [[position]],
                                constant float2& res[[buffer(0)]],
                                constant float3& accel[[buffer(3)]])
{
    float2 uv = pixPos.xy/min(res.x, res.y);
    
    float3 col = 0.0;
    
    float2 center = uv - 0.5;
    center += accel.xy;
    col = step(length(center), 0.5);
    
    return float4(col, 1.0);
}

fragment float4 BlockNoiseCamera(float4 pixPos [[position]],
                                 constant float2& res[[buffer(0)]],
                                 constant float& time[[buffer(1)]],
                                 texture2d<float, access::sample> texture[[texture(1)]])
{
    float4 col = 0;

    float2 uv = pixPos.xy/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv.y += 0.3 * time;

    constexpr float blocksize = 20.0;
    constexpr float distortion = 0.2;
    
    uv *= blocksize;
    float2 id = floor(uv);
    
    float noise = 2.0*(N21(id) - 0.5);

    float outputmask = step(abs(noise), 0.2);
    noise *= outputmask;
    
    constexpr sampler s(address::repeat, filter::linear);
    float2 texUV = pixPos.xy/res;
    
    col = float4(texture.sample(s, texUV - distortion * noise));
    
    return col;
}

fragment float4 Camera(float4 pixPos [[position]],
                      constant float2& res[[buffer(0)]],
                      texture2d<float, access::sample> texture[[texture(1)]])
{
    float4 col = 0;
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float2 uv = pixPos.xy/res;
    col = float4(texture.sample(s, uv));
    col.rgb = dot(col.rgb, float3(0.2126, 0.7152, 0.0722));

    return col;
}
