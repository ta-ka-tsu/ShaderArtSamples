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

// 原点中心半径radiusの球
float dSphere(float3 p, float radius) {
    return length(p) - radius;
}

// Y = 0の平面
float dPlane(float3 p) {
    return p.y;
}

// カプセル
float dCapsule(float3 p, float3 p1, float3 p2, float radius) {
    float3 dir21 = p2 - p1;
    float3 dir1ToP = p - p1;
    float t = dot(dir21, dir1ToP)/length_squared(dir21);
    t = clamp(t, 0.0, 1.0);
    float3 c = p1 + t*dir21;
    return distance(p, c) - radius;
}

// 原点中心 Y平面に平行
float dTorus(float3 p, float majorR, float minorR) {
    float x = length(p.xz) - majorR;
    return length(float2(x, p.y)) - minorR;
}

// 原点中心
float dBox(float3 p, float3 size) {
    float3 d = abs(p) - size;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

// 無限シリンダー
float dInfCylinder(float3 p, float3 p1, float3 p2, float radius) {
    float3 dir21 = p2 - p1;
    float3 dir1ToP = p - p1;
    float t = dot(dir21, dir1ToP)/length_squared(dir21);
    float3 c = p1 + t*dir21;
    return distance(p, c) - radius;
}

// 有限シリンダー
float dCylinder(float3 p, float3 p1, float3 p2, float radius) {
    float3 dir21 = p2 - p1;
    float3 dir1ToP = p - p1;
    float t = dot(dir21, dir1ToP)/length_squared(dir21);
    float3 c = p1 + t*dir21;
    
    float x = distance(p, c) - radius;
    float y = (abs(t - 0.5) - 0.5)*length(dir21);
    float e = length(max(float2(x, y), 0.0));

    return e;
}

float smoothmin(float d1, float d2, float k) {
    float h = exp(-k*d1) + exp(-k*d2);
    return -log(h)/k;
}

float GetDistance(float3 p) {
    float d = dPlane(p);
    d = min(d, dBox(p - float3(0.0, 0.5, 3.0), float3(0.5, 0.5, 0.5)));
    d = min(d, dSphere(p - float3(2.0, 1.0, 6.0), 1.0));
    d = min(d, dTorus(p - float3(-1.0, 0.5, 6.0), 1.5, 0.3));
    d = min(d, dCapsule(p, float3(3.0, 1.0, 3.0), float3(4.0, 2.0, 5.0), 0.3));
    d = min(d, dCylinder(p, float3(1.5, 0.0, 3.0), float3(1.5, 1.0, 3.0), 0.5));
    d = min(d, dInfCylinder(p, float3(-3.5, 0.0, 5.0), float3(-3.5, 1.0, 5.0), 0.5));
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
    float3 toLightDir = GetPointLightDirection(p, float3(0.0, 5.0, 2.0));
    float3 normal = GetNormal(p);
    
    float diffuse = dot(normal, toLightDir);
    
    float d = RayMarch(p + 2.0 * HIT_DIST*normal, toLightDir);
    if (d < distance(p, toLightDir)) diffuse *= 0.2;
    return diffuse;
}

fragment float4 RayMarching1(float4 pixPos [[position]],
                             constant float2& res[[buffer(0)]],
                             constant float& time [[buffer(1)]]) {
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float3 ro = float3(0.0, 2.0, 0.0);
    float3 rd = normalize(float3(uv.x, uv.y, 1.0));
    
    float d = RayMarch(ro, rd);
    
    float3 p = ro + rd * d;
    float3 col = GetLight(p, time);
    
    return float4(col, 1.0);
}
