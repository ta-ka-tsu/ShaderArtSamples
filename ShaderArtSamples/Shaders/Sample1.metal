//
//  Sample1.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/19.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

fragment float4 Sample1_1(float4 pixPos [[position]])
{
    return float4(1.0, 0.0, 0.0, 1.0);
}

fragment float4 Sample1_2(float4 pixPos [[position]])
{
    return length(pixPos.xy)/300.0;
}

fragment float4 Sample1_3(float4 pixPos [[position]])
{
    return step(300.0, length(pixPos.xy));
}

fragment float4 Sample1_4(float4 pixPos [[position]])
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

fragment float4 Sample1_5(float4 pixPos [[position]])
{
    return HSprite(pixPos.xy, 100.0);
}

fragment float4 Sample1_6(float4 pixPos [[position]])
{
    return VSprite(pixPos.xy, 100.0);
}

// or演算
fragment float4 Sample1_7(float4 pixPos [[position]])
{
    float h = HSprite(pixPos.xy, 100.0);
    float v = VSprite(pixPos.xy, 100.0);
    return max(h, v);
}

// and演算
fragment float4 Sample1_8(float4 pixPos [[position]])
{
    float h = HSprite(pixPos.xy, 100.0);
    float v = VSprite(pixPos.xy, 100.0);
    return h*v;
}

// xor演算
fragment float4 Sample1_9(float4 pixPos [[position]])
{
    float h = HSprite(pixPos.xy, 100.0);
    float v = VSprite(pixPos.xy, 100.0);
    return abs(h - v);
}

// not演算
fragment float4 Sample1_10(float4 pixPos [[position]])
{
    float h = HSprite(pixPos.xy, 100.0);
    return 1-h;
}
