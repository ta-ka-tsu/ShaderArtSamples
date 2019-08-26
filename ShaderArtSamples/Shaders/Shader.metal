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

// グリッド毎にサイズを変えた円(中心版)+アニメーション
fragment float4 Sample2_10(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv = rot(time) * uv;
    
    uv = 2.0 * uv + 0.5;
    float2 id = floor(uv);
    uv = fract(uv) * 2.0 - 1.0;
    
    float threshold = exp(-(0.5*sin(2.0*time)+0.5)*length(id));
    return step(length(uv), threshold);
}

// polar mod
fragment float4 Sample2_11(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float angle = M_PI_F/5;
    
    float pid = floor(theta/angle);
    
    uv = rot(-(pid + 0.5) * angle)*uv;

    uv.y += 0.5;
    uv.x -= time;
    float2 aspect(5.0, 1.0);
    float2 grid = aspect * uv;
    float2 st = 2.0 * fract(grid) - 1.0;
    st /= aspect;
    return step(length(st), 0.1);
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
