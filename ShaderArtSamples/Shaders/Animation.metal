//
//  Animation.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/31.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

// 回転する星
fragment float4 Animation1(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x) - time;
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// 円と星のモーフィング
fragment float4 Animation2(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float amp = 0.2 * sin(time);
    float threshold = amp*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}
