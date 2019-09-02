//
//  Texture.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/26.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

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

// テクスチャ(正方向、クランプ)
fragment float4 Texture3(float4 pixPos [[position]],
                         constant float2& res[[buffer(0)]],
                         texture2d<float> tex[[texture(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    
    constexpr sampler s(address::repeat, filter::linear);
    return tex.sample(s, uv);
}

// ノイズ
fragment float4 Texture4(float4 pixPos [[position]],
                         constant float2& res[[buffer(0)]],
                         texture2d<float> tex[[texture(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    
    constexpr sampler s(address::repeat, filter::linear);
    
    float idY = floor(uv.y * 40);
    float d = N11(idY);
    float offset = 0.1 * step(0.8, d);
    
    uv.x += offset;
    return tex.sample(s, uv);
}
