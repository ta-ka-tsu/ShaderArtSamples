//
//  RainyCamera.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/16.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


float N21(float2 p) {
    return fract(sin(dot(p, float2(12.9898, 78.233)))*43758.5453123);
}


float3 RainyLayer(float2 UV, float t) {
    const float SIZE = 2.0;
    
    float2 aspect = float2(2, 1);
    
    float2 uv = SIZE * UV * aspect;
    uv.y += t * 0.25;
    float2 gv = fract(uv) - 0.5;
    float2 id = floor(uv);
    
    float n = N21(id);
    t += 2.0 * M_PI_F * n;
    
    float w = UV.y * 10.0;
    float x = (n - 0.5) * 0.8;
    x += (0.4 - abs(x)) * 0.45 * sin(3.0*w) * pow(sin(w), 6.0);
    float y = -sin(t + sin(t + sin(t)*0.5)) * 0.45;
    y -= (gv.x - x)*(gv.x - x);
    
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, t * 0.25))/aspect;
    trailPos.y = (fract(trailPos.y * 8.0) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    float fogTrail = smoothstep(-0.05, 0.05, dropPos.y);
    fogTrail *= 1.0 - smoothstep(y, 0.5, gv.y);
    trail *= fogTrail;
    fogTrail *= 1.0 - smoothstep(0.04, 0.05, abs(dropPos.x));
    
    float2 offset = drop * dropPos + trail * trailPos;
    
    return float3(offset, fogTrail);
}

fragment float4 RainyCamera(float4 pixPos [[position]],
                            constant float2 &res[[buffer(0)]],
                            constant float &time[[buffer(1)]],
                            texture2d<float, access::sample> texture[[texture(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float4 col = 0;
    
    float t = time;
    
    float DISTORTION = -5.0;
    float BLUR = 0.63;
    
    float3 drops = 0.0;
    drops += RainyLayer(pos, t);
    drops += RainyLayer(1.23 * pos + 7.54, t);
    drops += RainyLayer(1.35 * pos + 1.54, t);
    //    drops += WaterLayer(1.57 * pos - 7.54, t);
    
    float blur = BLUR * 7.0 * (1.0 - drops.z);
    
    float2 texUV = pixPos.xy/res;
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    blur *= 0.01;
    const float numSamples = 32;
    float a = N21(pos) * 2.0 * M_PI_F;
    for (float i = 0.0; i < numSamples ; ++i) {
        float2 offset = float2(sin(a), cos(a))*blur;
        float d = fract(sin((i + 1.0) * 546.0) * 5424.0);
        d = sqrt(d);
        offset *= d;
        col += texture.sample(s, texUV + offset + DISTORTION * drops.xy);
        ++a;
    }
    col /= numSamples;
    
    return col;
}
