//
//  RayMarching.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/16.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

static constant int MAX_STEPS = 100;
static constant float MAX_DIST = 100.0;
static constant float HIT_DIST = 0.01;
static constant float EPS = 0.0001;

struct Sphere {
    float3 center;
    float radius;
    Sphere(float3 c, float r) : center(c), radius(r) {
    }
    
    float GetDistance(float3 p) {
        return distance(p, center) - radius;
    }
};

struct Plane {
    // Coefficient ax + by + cz + d = 0
    float a;
    float b;
    float c;
    float d;
    Plane(float a, float b, float c, float d) : a(a), b(b), c(c), d(d) {
    }
    
    float GetDistance(float3 p) {
        return abs(a * p.x + b * p.y + c * p.z + d)/sqrt(a * a + b * b + c * c);
    }
};

struct Capsule {
    float3 point1;
    float3 point2;
    float radius;
    Capsule(float3 p1, float3 p2, float r) : point1(p1), point2(p2), radius(r) {
    }
    
    float GetDistance(float3 p) {
        float3 dir21 = point2 - point1;
        float3 dir1ToP = p - point1;
        float t = dot(dir21, dir1ToP)/length_squared(dir21);
        t = clamp(t, 0.0, 1.0);
        float3 c = point1 + t*dir21;
        return distance(p, c) - radius;
    }
};

struct Torus {// XZ Aligned
    float3 center;
    float majorRadius;
    float minorRadius;
    Torus(float3 center, float majorR, float minorR) : center(center), majorRadius(majorR), minorRadius(minorR) {
    }

    float GetDistance(float3 p) {
        float x = length(p.xz - center.xz) - majorRadius;
        return length(float2(x, p.y - center.y)) - minorRadius;
    }
};

struct Box {// XYZ Aligned Box
    float3 center;
    float3 size;
    Box(float3 center, float3 size) : center(center), size(size) {
    }
    
    float GetDistance(float3 p) {
        return length(max(abs(p - center) - size, 0.0));
    }
};

struct InfiniteCylinder {
    float3 point1;
    float3 point2;
    float radius;
    InfiniteCylinder(float3 p1, float3 p2, float r) : point1(p1), point2(p2), radius(r) {
    }
    
    float GetDistance(float3 p) {
        float3 dir21 = point2 - point1;
        float3 dir1ToP = p - point1;
        float t = dot(dir21, dir1ToP)/length_squared(dir21);
        float3 c = point1 + t*dir21;
        return distance(p, c) - radius;
    }
};

struct Cylinder {
    float3 point1;
    float3 point2;
    float radius;
    Cylinder(float3 p1, float3 p2, float r) : point1(p1), point2(p2), radius(r) {
    }
    
    float GetDistance(float3 p) {
        float3 dir21 = point2 - point1;
        float3 dir1ToP = p - point1;
        float t = dot(dir21, dir1ToP)/length_squared(dir21);
        float3 c = point1 + t*dir21;
        
        float x = distance(p, c) - radius;
        float y = (abs(t - 0.5) - 0.5)*length(dir21);
        float e = length(max(float2(x, y), 0.0));
//        float i = min(max(x, y), 0.0);
        
        return e;
    }
};

float smoothmin(float d1, float d2, float k) {
    float h = exp(-k*d1) + exp(-k*d2);
    return -log(h)/k;
}

float GetDistance(float3 p) {
    Plane plane1(0.0, 1.0, 0.0, 0.0);
    Sphere sphere1(float3(0.0, 1.0, 6.0), 1.0);
    Capsule capsule1(float3(0.0, 1.0, 6.0), float3(1.0, 2.0, 6.0), 0.2);
    Torus torus1(float3(0.0, 0.5, 6.0), 1.5, 0.3);
    Box box1(float3(-2.0, 0.5, 6.0), float3(0.5, 0.5, 0.5));
    InfiniteCylinder cylinder1(float3(3.0, 1.0, 7.0), float3(2.0, 2.0, 7.0), 0.1);
    Cylinder cylinder2(float3(0.0, 1.0, 5.0), float3(1.0, 2.0, 7.0), 0.5);

    return smoothmin(plane1.GetDistance(p), cylinder1.GetDistance(p), 1.1);
//    return min(plane1.GetDistance(p), box1.GetDistance(p));
//    return min(plane1.GetDistance(p), torus1.GetDistance(p));
//    return min(plane1.GetDistance(p), capsule1.GetDistance(p));
//    return min(plane1.GetDistance(p), sphere1.GetDistance(p));
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

float GetLight(float3 p, float time) {
    float3 lightPos(0.0, 5.0, 6.0);
    lightPos.xz += float2(sin(time), cos(time));
    float3 toLightDir = normalize(lightPos - p);
    float3 normal = GetNormal(p);
    
    float diffuse = dot(normal, toLightDir);
    
    float d = RayMarch(p + 2.0 * HIT_DIST*normal, toLightDir);
    if (d < distance(p, toLightDir)) diffuse *= 0.2;
    return diffuse;
}

fragment float4 RayMarching(float4 pixPos [[position]],
                            constant float2& res[[buffer(0)]],
                            constant float& time [[buffer(1)]]) {
    float2 uv = (pixPos.xy - 0.5 * res)/min(res.x, res.y);
    uv = float2(uv.x, -uv.y);
    
    float3 ro = float3(0.0, 2.0, 0.0);
    float3 rd = normalize(float3(uv.x, uv.y, 1.0));
    
    float d = RayMarch(ro, rd);
    
    float3 p = ro + rd * d;

    float3 col = GetLight(p, time);
    
    return float4(col, 1.0);
}
