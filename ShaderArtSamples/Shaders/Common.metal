//
//  Common.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/25.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


float N11(float v) {
    return fract(sin(v)*43758.5453123);
}

float N21(float2 p) {
    return N11(dot(p, float2(12.9898, 78.233)));
}

float3 hsv2rgb(float h, float s, float v) {
    float3 a = fract(h + float3(0.0, 2.0, 1.0)/3.0)*6.0-3.0;
    a = clamp(abs(a) - 1.0, 0.0, 1.0) - 1.0;
    a = a*s + 1.0;
    return a*v;
    //    return ((clamp(abs(fract(h+float3(0,2,1)/3.0)*6.0-3.0)-1.0,0.0,1.0)-1.0)*s+1.0)*v;
}

float grid(float2 p)
{
    float g = 0.0;
    p = fract(p);
    g = max(g, step(0.98, p.x));
    g = max(g, step(0.98, p.y));
    return g;
}

float2x2 rot(float radian)
{
    float c = cos(radian);
    float s = sin(radian);
    
    return float2x2(c, s, -s, c);
}
