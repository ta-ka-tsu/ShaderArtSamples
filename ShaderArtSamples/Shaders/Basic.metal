//
//  Basic.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/19.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

fragment float4 Basic1(float4 pixPos [[position]])
{
    return float4(1.0, 0.0, 0.0, 1.0);
}

fragment float4 Basic2(float4 pixPos [[position]])
{
    return length(pixPos.xy)/300.0;
}

fragment float4 Basic3(float4 pixPos [[position]])
{
    return step(300.0, length(pixPos.xy));
}

fragment float4 Basic4(float4 pixPos [[position]])
{
    return smoothstep(300.0, 400.0, length(pixPos.xy));
}

float HSprite(float2 pos, float thickness)
{
    return step(0.0, sinpi(pos.x/thickness));
}

float VSprite(float2 pos, float thickness)
{
    return HSprite(pos.yx, thickness);
}

fragment float4 Basic5(float4 pixPos [[position]])
{
    return HSprite(pixPos.xy, 100.0);
}

fragment float4 Basic6(float4 pixPos [[position]])
{
    return VSprite(pixPos.xy, 100.0);
}

// or演算
fragment float4 Basic7(float4 pixPos [[position]])
{
    float h = HSprite(pixPos.xy, 100.0);
    float v = VSprite(pixPos.xy, 100.0);
    return max(h, v);
}

// and演算
fragment float4 Basic8(float4 pixPos [[position]])
{
    float h = HSprite(pixPos.xy, 100.0);
    float v = VSprite(pixPos.xy, 100.0);
    return h*v;
}

// xor演算
fragment float4 Basic9(float4 pixPos [[position]])
{
    float h = HSprite(pixPos.xy, 100.0);
    float v = VSprite(pixPos.xy, 100.0);
    return abs(h - v);
}

// not演算
fragment float4 Basic10(float4 pixPos [[position]])
{
    float h = HSprite(pixPos.xy, 100.0);
    return 1-h;
}

// 円
fragment float4 Basic11(float4 pixPos [[position]],
                         constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    return step(length(uv), 1.0);
}

// ダイヤ
fragment float4 Basic12(float4 pixPos [[position]],
                         constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float manhattanDist = abs(uv.x) + abs(uv.y);
    return step(manhattanDist, 1.0);
}

// 四角
fragment float4 Basic13(float4 pixPos [[position]],
                         constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float chebyshevDist = max(abs(uv.x), abs(uv.y));
    return step(chebyshevDist, 1.0);
}
