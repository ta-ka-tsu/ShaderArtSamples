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


// 音に応じて星の大きさを変える
fragment float4 Demo1(float4 pixPos [[position]],
                      constant float2& res[[buffer(0)]],
                      constant float& time[[buffer(1)]],
                      constant float& volume[[buffer(2)]],
                      constant float3& accel[[buffer(3)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;

    uv *= 1.0/clamp(volume, 0.1, 1.0);
    
    float t = 0.2 * sin(5 * atan2(uv.y, uv.x)) + 0.8;
    return step(length(uv), t);
}

// タッチ位置を中心に歪ませる
fragment float4 Demo2(float4 pixPos [[position]],
                      constant float2& res[[buffer(0)]],
                      constant float& time[[buffer(1)]],
                      constant float2& touch[[buffer(4)]])
{
    float2 uv = 2.0 * (pixPos.xy - touch)/min(res.x, res.y);
    uv.y *= -1.0;

    uv *= 2.0;

    float l = length(uv);
    float2 uv2 = uv*(1 - 0.8*exp(-0.2*l*l) * (0.4 * cos(16*l)));
    
    return grid(uv2);
    
    uv2 = 2*fract(uv2) - 1;
    
    float threshold = 0.2 * sin(5*atan2(uv2.y, uv2.x) - time) + 0.8;
    return step(length(uv2), threshold);//grid(uv2);
}

// 指で右になぞるほど解像度が荒くなるカメラ
fragment float4 Demo3(float4 pixPos [[position]],
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
