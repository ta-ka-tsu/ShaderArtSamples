//
//  Common.h
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/25.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#ifndef Common_h
#define Common_h

// Noise
float N11(float s);
float N21(float2 p);
float3 hsv2rgb(float h, float s, float v);

// Gereral Mod
float mod(float a, float b);

// Grid
float grid(float2 p);

// Rotation
metal::float2x2 rot(float radian);

// Distance Fields
float dSphere(float3 p, float radius);
float dPlane(float3 p);
float dCapsule(float3 p, float3 p1, float3 p2, float radius);
float dTorus(float3 p, float majorR, float minorR);
float dBox(float3 p, float3 size);
float dInfCylinder(float3 p, float3 p1, float3 p2, float radius);
float dCylinder(float3 p, float3 p1, float3 p2, float radius);

#endif /* Common_h */
