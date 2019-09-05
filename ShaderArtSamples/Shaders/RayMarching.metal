//
//  RayMarching.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/16.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

static constant int MAX_STEPS = 100;
static constant float MAX_DIST = 100.0;
static constant float HIT_DIST = 0.01;
static constant float EPS = 0.0001;


float smoothmin(float d1, float d2, float k) {
    float h = exp(-k*d1) + exp(-k*d2);
    return -log(h)/k;
}

float GetDistance(float3 p) {
    float d = dPlane(p);
    d = min(d, dBox(p - float3(-2.0, 0.7, 8.0), float3(0.7, 0.7, 0.7)));
    d = min(d, dSphere(p - float3(4.0, 4.5, 24.0), 2.0));
    d = min(d, dTorus(p - float3(-1.0, 1.0, 12.0), 1.5, 0.4));
    d = min(d, dCapsule(p, float3(3.0, 1.0, 18.0), float3(3.5, 2.0, 10.0), 0.3));
    d = min(d, dCylinder(p, float3(1.5, 0.0, 8.0), float3(1.5, 1.0, 8.0), 0.5));
    d = min(d, dInfCylinder(p, float3(-5.5, 0.0, 15.0), float3(-5.5, 1.0, 15.0), 0.5));
    return d;
}

float3 GetNormal(float3 p) {
    float d = GetDistance(p);
    float2 eps = float2(EPS, 0.0);
    float3 n = d - float3(GetDistance(p - eps.xyy), GetDistance(p - eps.yxy), GetDistance(p - eps.yyx));
    return normalize(n);
}

float RayMarch(float3 ro, float3 rd) {
    float d = 0.0;
    for (int i = 0; i < MAX_STEPS ; ++i) {
        float3 p = ro + d * rd;
        float ds = GetDistance(p);
        d += ds;
        if (ds < HIT_DIST || d > MAX_DIST) break;
    }
    return d;
}

float3 GetPointLightDirection(float3 from, float3 lightPos) {
    return normalize(lightPos - from);
}

float GetLight(float3 p, float time) {
    float3 toLightDir = GetPointLightDirection(p, float3(2.0*sin(time), 5.0, 5.0*cos(time)));
    float3 normal = GetNormal(p);
    
    float diffuse = dot(normal, toLightDir);
    
    float d = RayMarch(p + 2.0 * HIT_DIST*normal, toLightDir);
    if (d < distance(p, toLightDir)) diffuse *= 0.2;
    return diffuse;
}

fragment float4 RayMarching(float4 pixPos [[position]],
                            constant float2& res[[buffer(0)]],
                            constant float& time [[buffer(1)]]) {
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float3 ro = float3(0.0, 2.0, 0.0);
    float3 rd = normalize(float3(uv.x, uv.y, 3.0));
    
    float d = RayMarch(ro, rd);
    
    float3 p = ro + rd * d;
    float3 col = GetLight(p, time);
    
    return float4(col, 1.0);
}
