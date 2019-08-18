//
//  Shader.metal
//  ShaderArtSamples
//
//  Created by TakatsuYouichi on 2019/07/14.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

fragment float4 Sample1_1_AllRed(float4 pixPos [[position]])
{
    return float4(1.0, 0.0, 0.0, 1.0);
}

fragment float4 Sample1_2(float4 pixPos [[position]],
                         constant float2 &res[[buffer(0)]])
{
    float2 uv = pixPos.xy/min(res.x, res.y);
    return float4(uv, 0.0, 1.0);
}

fragment float4 Sample1_3(float4 pixPos [[position]],
                         constant float2 &res[[buffer(0)]],
                         constant float &time[[buffer(1)]])
{
    float2 uv = pixPos.xy/min(res.x, res.y);
    float3 col = step(0.5 * sin(time) + 0.5, length(uv));
    return float4(col, 1.0);
}

fragment float4 Sample1_4(float4 pixPos [[position]],
                         constant float2 &res[[buffer(0)]],
                         constant float &vol[[buffer(2)]])
{
    float2 uv = pixPos.xy/min(res.x, res.y);
    return float4(step(length(uv - 0.5), 0.5*vol), 0.0, 0.0, 1.0);
}

fragment float4 Sample1_5_Accel(float4 pixPos [[position]],
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
