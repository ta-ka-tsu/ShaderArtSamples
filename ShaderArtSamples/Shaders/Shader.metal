//
//  Shader.metal
//  ShaderArtSamples
//
//  Created by TakatsuYouichi on 2019/07/14.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;


fragment float4 Sample2_1(float4 pixPos [[position]],
                          constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    return step(length(uv), 1.0);
}

// カージオイド
fragment float4 Sample2_2(float4 pixPos [[position]],
                          constant float2 &res[[buffer(0)]],
                          constant float &time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.5 * sin(theta) + 0.5;
    return step(length(uv), threshold);
}

// 花？
fragment float4 Sample2_3(float4 pixPos [[position]],
                          constant float2 &res[[buffer(0)]],
                          constant float &time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.5*sin(5 * theta) + 0.5;
    return step(length(uv), threshold);
}

// 花？
fragment float4 Sample2_4(float4 pixPos [[position]],
                          constant float2 &res[[buffer(0)]],
                          constant float &time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.5*sin(5 * theta) + 0.5;
    return step(length(uv), threshold);
}

fragment float4 Sample2_5(float4 pixPos [[position]],
                          constant float2 &res[[buffer(0)]],
                          constant float &time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = min(0.6*abs(sin(2.5*theta))+0.4, 0.3 * abs(cos(2.5*theta))+0.9);
    return step(length(uv), threshold);
}

fragment float4 Sample2_6(float4 pixPos [[position]],
                          constant float2 &res[[buffer(0)]],
                          constant float &time[[buffer(1)]])
{
    float2 uv = pixPos.xy/min(res.x, res.y);
    float3 col = step(0.5 * sin(time) + 0.5, length(uv));
    return float4(col, 1.0);
}

fragment float4 Sample1_7(float4 pixPos [[position]],
                         constant float2 &res[[buffer(0)]],
                         constant float &vol[[buffer(2)]])
{
    float2 uv = pixPos.xy/min(res.x, res.y);
    return float4(step(length(uv - 0.5), 0.5*vol), 0.0, 0.0, 1.0);
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

fragment float4 Camera(float4 pixPos [[position]],
                      constant float2 &res[[buffer(0)]],
                      texture2d<float, access::sample> texture[[texture(0)]])
{
    float4 col = 0;
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float2 uv = pixPos.xy/res;
    col = float4(texture.sample(s, uv));

    return col;
}
