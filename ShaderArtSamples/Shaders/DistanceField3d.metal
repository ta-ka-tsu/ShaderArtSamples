//
//  DistanceField3d.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/09/01.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

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
