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

