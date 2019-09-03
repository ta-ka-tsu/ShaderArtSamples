//
//  Demo.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/09/01.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

// sinの組み合わせ
fragment float4 Demo1(float4 pixPos [[position]],
                      constant float2& res[[buffer(0)]],
                      constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 8.0;
    
    float v1 = 0.5 * sin(uv.x + time) + 0.5;
    float v2 = 0.5 * sin(uv.y + time) + 0.5;
    float v3 = 0.5 * sin(uv.x + uv.y + time) + 0.5;
    float v4 = 0.5 * sin(length(uv) + time) + 0.5;
    float sum = (v1 + v2 + v3 + v4)/4.0;

    return float4(hsv2rgb(sin(sum), 0.7, 1.0), 1.0);
}

fragment float4 Demo2(float4 pixPos [[position]],
                      constant float2& res[[buffer(0)]],
                      constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2;
    
    uv.x += 0.5 * sin(uv.y + time) + 0.5;
    uv.y += 0.5 * sin(uv.x + time) + 0.5;
    
    float2 id = floor(uv);
    uv = fract(uv);
    uv -= 0.5;
    
    float noise = N21(id);
    float scale = sin(time + noise * M_PI_F);
    float theta = atan2(uv.y, uv.x) - time;
    float threshold = scale * (0.25*sin(5*theta)+0.25);
    
    float hue = fract(noise + time);
    float4 col = float4(hsv2rgb(hue, 0.7, 1.0), 1.0);
    
    return col * step(length(uv), threshold);
}

// 複製＋歪＋色相＋マスク
fragment float4 Demo3(float4 pixPos [[position]],
                      constant float2& res[[buffer(0)]],
                      constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2.0;
    
    uv *= 1.0 + 0.4 * length(uv);
    
    float rotDir = sign(uv.x) * sign(uv.y);
    float2 id = floor(uv) + 0.5;
    float hue = fract(atan2(id.y, id.x)/M_PI_F) + 0.1 * time;
    
    
    float size = 0.2* sin(1.5 * length(id) - 2.0 * time) + 0.8;
    
    uv = 2.0 * fract(uv) - 1.0;
    
    float theta = atan2(uv.y, uv.x) + rotDir * time;
    float threshold = 0.65 * min(abs(sin(2.5 * theta)), abs(cos(2.5 * theta)) + 0.8) + 0.35;
    float flower = step(length(uv), size * threshold);
    
    return float4(flower * hsv2rgb(hue, 0.6, 1.0), 1.0);
}


// 音に応じて星の大きさを変える
fragment float4 InteractionDemo1(float4 pixPos [[position]],
                                 constant float2& res[[buffer(0)]],
                                 constant float& volume[[buffer(2)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 1.0/clamp(volume, 0.1, 0.9);
    
    float t = 0.2 * sin(5 * atan2(uv.y, uv.x)) + 0.8;
    float4 yellowy = mix(float4(1.0, 1.0, 1.0, 1.0), float4(1.0, 1.0, 0.0, 1.0), smoothstep(0.6, 0.9, volume));
    
    return step(length(uv), t)*yellowy;
}

// 指で右になぞるほど解像度が荒くなるカメラ
fragment float4 InteractionDemo2(float4 pixPos [[position]],
                                 constant float2& res[[buffer(0)]],
                                 constant float2& touch[[buffer(4)]],
                                 texture2d<float> texture[[texture(1)]])
{
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float2 uv = pixPos.xy/res;
    
    float ratio = touch.x/res.x;
    float xDivider = (res.x - 10.0)*exp(-10.0*ratio) + 10;
    float2 showRes = xDivider * float2(1.0, res.y/res.x);
    
    uv = floor(showRes*uv)/showRes;
    
    return float4(texture.sample(s, uv));
}

// 水平方向を向かないとノイズが入るカメラ
fragment float4 InteractionDemo3(float4 pixPos [[position]],
                                 constant float2& res[[buffer(0)]],
                                 constant float& time[[buffer(1)]],
                                 constant float3& accel[[buffer(3)]],
                                 texture2d<float, access::sample> texture[[texture(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float sandNoise = N21(uv + M_PI_F * fract(5.0 * time));
    
    float idY = floor(res.y * uv.y / 5.0);
    float horizontalNoise = N11(idY + M_PI_F * fract(time));
    
    float outputmask = step(1.0 - 2.0 * accel.y * accel.y, horizontalNoise);
    horizontalNoise *= outputmask;
    
    constexpr sampler s(address::repeat, filter::linear);
    float2 texUV = pixPos.xy/res;
    
    float4 camera = texture.sample(s, texUV + 0.05 * N11(horizontalNoise));
    
    float clarity = 1.0 - smoothstep(-0.98, -0.9, accel.x);
    return mix(sandNoise, camera, clarity);
}

