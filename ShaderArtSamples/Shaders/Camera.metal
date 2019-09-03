//
//  Camera.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/09/03.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment float4 GrayCamera(float4 pixPos [[position]],
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

fragment float4 LensCamera(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]],
                           texture2d<float> tex[[texture(1)]])
{
    float4 col = 0.0;
    
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    
    float size = 0.7;
    float mask = step(length(uv), size);
    float distortion = -0.9;
    float2 offset = distortion * sqrt(length(uv)) * uv * mask;
    
    float2 texUV = pixPos.xy/res;
    constexpr sampler s(address::repeat, filter::linear);
    col = tex.sample(s, texUV + offset);
    
    return col;
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
    
    float noise = 2.0*(N21(id) + N11(floor(3 * time)) - 0.5);
    
    float outputmask = step(abs(noise), 0.2);
    noise *= outputmask;
    
    constexpr sampler s(address::repeat, filter::linear);
    float2 texUV = pixPos.xy/res;
    
    col = float4(texture.sample(s, texUV - distortion * noise));
    
    return col;
}

// 加速度に応じてカメラ・テクスチャをブロックノイズで切り替える
fragment float4 TextureAndCamera(float4 pixPos [[position]],
                                 constant float2& res[[buffer(0)]],
                                 constant float3& accel[[buffer(3)]],
                                 texture2d<float> tex[[texture(0)]],
                                 texture2d<float> cam[[texture(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    
    float2 texUV = pixPos.xy/res;
    constexpr sampler s(address::repeat, filter::linear);
    
    float4 cameraImage = cam.sample(s, texUV);
    float4 textureImage = tex.sample(s, uv);
    
    float noise = clamp(N21(floor(10.0 * uv)) + 0.01, 0.0, 0.99);
    float acc = clamp(-accel.x, 0.0, 1.0);
    float blend = step(acc, noise);
    
    return mix(cameraImage, textureImage, blend);
}
