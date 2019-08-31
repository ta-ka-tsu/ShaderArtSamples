//
//  DistortedSpace.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/25.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;


fragment float4 Distorted1(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    return red * grid(uv);
}

fragment float4 Distorted2(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2;

    uv.x += sin(uv.y);
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    return red * grid(uv);
}

fragment float4 Distorted3(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2;

    uv.x += sin(uv.y);
    uv.y += sin(uv.x);

    float4 red(1.0, 0.0, 0.0, 1.0);
    return red * grid(uv);
}

fragment float4 Distorted4(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2;

    uv.x += 0.5 * sin(uv.y + time) + 0.5;
    uv.y += 0.5 * sin(uv.x + time) + 0.5;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    return red * grid(uv);
}

fragment float4 Distorted5(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2;
    
    uv *= 1.0 + (0.1 * sin(time) + 0.1) * length(uv);
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    return red * grid(uv);
}

fragment float4 Distorted6(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2;

    uv.x += 0.5 * sin(uv.y + time) + 0.5;
    uv.y += 0.5 * sin(uv.x + time) + 0.5;
    
    uv = fract(uv);
    uv -= 0.5;
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.25*sin(5*theta)+0.25;
    return step(length(uv), threshold);
}

fragment float4 Distorted7(float4 pixPos [[position]],
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

fragment float4 Distorted8(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 5;
    
    float2 polar(length(uv), 12 / M_PI_F * atan2(uv.y, uv.x));
    polar = 2.0*fract(polar) - 1.0;

    float phase = atan2(polar.y, polar.x);
    float t = 0.25 * sin(5*phase + 2.0* time) + 0.75;
    return step(length(polar), t);
}
