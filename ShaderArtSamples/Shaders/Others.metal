//
//  Others.metal
//  ShaderArtSamples
//
//  Created by TakatsuYouichi on 2019/07/14.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment float4 Stars(float4 pixPos [[position]],
                      constant float2& res[[buffer(0)]],
                      constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 5;
    
    float distCenterInUV = length(uv);
    
    float2 polar(length(uv) - time, 12 / M_PI_F * atan2(uv.y, uv.x));
    float2 id = floor(polar);
    polar = 2.0*fract(polar) - 1.0;
    
    float hue = N21(id);
    float4 col = float4(hsv2rgb(hue, smoothstep(0.0, 6.0, distCenterInUV), 1.0), 1.0);
    
    float phase = atan2(polar.y, polar.x) + time;
    float t = min(fract(3 * phase/M_PI_F), 1.0 - fract(3 * phase/M_PI_F)) + 0.5;
    return col * step(length(polar), t);
}

fragment float4 AccelSensor(float4 pixPos [[position]],
                            constant float2& res[[buffer(0)]],
                            constant float3& accel[[buffer(3)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    
    uv += accel.yx;
    return step(length(uv), 0.5);
}
