//
//  RainyCameraStepByStep.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/09/02.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

// 縦横比が異なる座標系にする
fragment float4 RainyCameraStep1(float4 pixPos [[position]],
                                 constant float2 &res[[buffer(0)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;

    return float4(1.0, 0.0, 0.0, 1.0) * grid(uv);
}

// グリッド内に円を書く
fragment float4 RainyCameraStep2(float4 pixPos [[position]],
                                 constant float2 &res[[buffer(0)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    float2 gv = fract(uv) - 0.5;

    float4 col = 0.0;

    float2 dropPos = gv/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));

    col += drop;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はcol
    return col;
}

// 時間に応じて丸の位置を動かす
fragment float4 RainyCameraStep3(float4 pixPos [[position]],
                                 constant float2 &res[[buffer(0)]],
                                 constant float &time[[buffer(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;
    
    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    float2 gv = fract(uv) - 0.5;
    
    float4 col = 0.0;
    
    float x = 0.0;
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    col += drop;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はcol
    return col;
}

// 時間に応じてグリッドも動かす
fragment float4 RainyCameraStep4(float4 pixPos [[position]],
                                 constant float2 &res[[buffer(0)]],
                                 constant float &time[[buffer(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;

    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    
    float4 col = 0.0;
    
    float x = 0.0;
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));

    col += drop;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はcol
    return col;
}

// グリッド内を8分割してその中に一回り小さい丸を書く　グリッドの動きを打ち消すように位置を移動し相対的に動かないようにする
fragment float4 RainyCameraStep5(float4 pixPos [[position]],
                                 constant float2 &res[[buffer(0)]],
                                 constant float &time[[buffer(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;

    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    
    float4 col = 0.0;
    
    float x = 0.0;
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, 0.25 * t))/aspect;
    trailPos.y = (fract(8.0 * trailPos.y) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    
    col += drop;
    col += trail;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はdrop
    return col;
}

// 大きな丸より上の位置だけにマスクをかける
fragment float4 RainyCameraStep6(float4 pixPos [[position]],
                                 constant float2 &res[[buffer(0)]],
                                 constant float &time[[buffer(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;

    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    
    float4 col = 0.0;
    
    float x = 0.0;
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, 0.25 * t))/aspect;
    trailPos.y = (fract(8.0 * trailPos.y) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    trail *= smoothstep(-0.05, 0.05, dropPos.y);
    
    col += drop;
    col += trail;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はdrop
    return col;
}

// グリッド内Y方向に応じてグラデーションをかける
fragment float4 RainyCameraStep7(float4 pixPos [[position]],
                                 constant float2 &res[[buffer(0)]],
                                 constant float &time[[buffer(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;

    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    
    float4 col = 0.0;
    
    float x = 0.0;
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, 0.25 * t))/aspect;
    trailPos.y = (fract(8.0 * trailPos.y) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    trail *= smoothstep(-0.05, 0.05, dropPos.y);
    trail *= 1.0 - smoothstep(y, 0.5, gv.y);
    col += drop;
    col += trail;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はdrop
    return col;
}

// 大きい丸を書く際に空間を歪ませて下側がすこし大きい感じの丸にする
fragment float4 RainyCameraStep8(float4 pixPos [[position]],
                                 constant float2 &res[[buffer(0)]],
                                 constant float &time[[buffer(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;

    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    
    float4 col = 0.0;
    
    float x = 0.0;
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    y -= (gv.x - x)*(gv.x - x);
    
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, 0.25 * t))/aspect;
    trailPos.y = (fract(8.0 * trailPos.y) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    trail *= smoothstep(-0.05, 0.05, dropPos.y);
    trail *= 1.0 - smoothstep(y, 0.5, gv.y);
    col += drop;
    col += trail;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はdrop
    return col;
}

// 位置に応じて左右に動かす
fragment float4 RainyCameraStep9(float4 pixPos [[position]],
                                 constant float2 &res[[buffer(0)]],
                                 constant float &time[[buffer(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;

    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    
    float4 col = 0.0;
    
    float w = pos.y * 10;
    float x = 0.45 * sin(3.0 * w)*pow(sin(w), 6.0);
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    y -= (gv.x - x)*(gv.x - x);
    
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, 0.25 * t))/aspect;
    trailPos.y = (fract(8.0 * trailPos.y) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    trail *= smoothstep(-0.05, 0.05, dropPos.y);
    trail *= 1.0 - smoothstep(y, 0.5, gv.y);
    col += drop;
    col += trail;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はdrop
    return col;
}

// グリッド毎にランダムに動かす
fragment float4 RainyCameraStep10(float4 pixPos [[position]],
                                  constant float2 &res[[buffer(0)]],
                                  constant float &time[[buffer(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;

    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    float2 id = floor(uv);
    
    float n = N21(id);
    t += 2.0 * M_PI_F * n;
    
    float4 col = 0.0;
    
    float w = pos.y * 10;
    float x = (n - 0.5) * 0.8;
    x += (0.4 - abs(x)) * sin(3.0 * w)*pow(sin(w), 6.0);
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    y -= (gv.x - x)*(gv.x - x);
    
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, 0.25 * t))/aspect;
    trailPos.y = (fract(8.0 * trailPos.y) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    trail *= smoothstep(-0.05, 0.05, dropPos.y);
    trail *= 1.0 - smoothstep(y, 0.5, gv.y);
    col += drop;
    col += trail;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はdrop
    return col;
}

// 通過位置のグラデーションだけを加える
fragment float4 RainyCameraStep11(float4 pixPos [[position]],
                                  constant float2 &res[[buffer(0)]],
                                  constant float &time[[buffer(1)]],
                                  texture2d<float, access::sample> texture[[texture(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;
    
    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    float2 id = floor(uv);
    
    float n = N21(id);
    t += 2.0 * M_PI_F * n;
    
    float4 col = 0.0;
    
    float w = pos.y * 10;
    float x = (n - 0.5) * 0.8;
    x += (0.4 - abs(x)) * sin(3.0 * w)*pow(sin(w), 6.0);
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    y -= (gv.x - x)*(gv.x - x);
    
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, 0.25 * t))/aspect;
    trailPos.y = (fract(8.0 * trailPos.y) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    float fogTrail = smoothstep(-0.05, 0.05, dropPos.y);
    fogTrail *= 1.0 - smoothstep(y, 0.5, gv.y);
    trail *= fogTrail;
    fogTrail *= 1.0 - smoothstep(0.04, 0.05, abs(dropPos.x));
    
    col += 0.5 * fogTrail;
    col += drop;
    col += trail;
    
    float4 red(1.0, 0.0, 0.0, 1.0);
    col = mix(col, red, grid(uv)); // gridの箇所はred, それ以外はdrop
    return col;
}

// dropPos, trailPosに応じてカメラからサンプルリングする点を変える。動かす量はdrop, trailに応じて変える
fragment float4 RainyCameraStep12(float4 pixPos [[position]],
                                  constant float2 &res[[buffer(0)]],
                                  constant float &time[[buffer(1)]],
                                  texture2d<float, access::sample> texture[[texture(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;
    
    float DISTORTION = -5.0;
    
    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    float2 id = floor(uv);
    
    float n = N21(id);
    t += 2.0 * M_PI_F * n;
    
    float w = pos.y * 10;
    float x = (n - 0.5) * 0.8;
    x += (0.4 - abs(x)) * sin(3.0 * w)*pow(sin(w), 6.0);
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    y -= (gv.x - x)*(gv.x - x);
    
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, 0.25 * t))/aspect;
    trailPos.y = (fract(8.0 * trailPos.y) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    float fogTrail = smoothstep(-0.05, 0.05, dropPos.y);
    fogTrail *= 1.0 - smoothstep(y, 0.5, gv.y);
    trail *= fogTrail;
    fogTrail *= 1.0 - smoothstep(0.04, 0.05, abs(dropPos.x));
    
    float2 offset = drop * dropPos + trail * trailPos;
    offset.y *= -1.0;
    
    float2 texUV = pixPos.xy/res;
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    return texture.sample(s, texUV + DISTORTION * offset);
}

// fogTrailが小さい箇所だけブラーをかける
fragment float4 RainyCameraStep13(float4 pixPos [[position]],
                                  constant float2 &res[[buffer(0)]],
                                  constant float &time[[buffer(1)]],
                                  texture2d<float, access::sample> texture[[texture(1)]])
{
    float2 pos = (pixPos.xy - float2(0.0, res.y)) * float2(1.0, -1.0)/min(res.x, res.y);
    
    float t = time;
    
    float2 DISTORTION = -5.0;
    float BLUR = 1.0;
    
    float size = 2.0;
    float2 aspect(2.0, 1.0);
    
    float2 uv = size * aspect * pos;
    uv.y += 0.25 * t;
    float2 gv = fract(uv) - 0.5;
    float2 id = floor(uv);
    
    float n = N21(id);
    t += 2.0 * M_PI_F * n;
    
    float4 col = 0.0;
    
    float w = pos.y * 10;
    float x = (n - 0.5) * 0.8;
    x += (0.4 - abs(x)) * sin(3.0 * w)*pow(sin(w), 6.0);
    float y = -0.45 * sin(t + sin(t + 0.5 *sin(t)));
    y -= (gv.x - x)*(gv.x - x);
    
    float2 dropPos = (gv - float2(x, y))/aspect;
    float drop = 1.0 - smoothstep(0.03, 0.05, length(dropPos));
    
    float2 trailPos = (gv - float2(x, 0.25 * t))/aspect;
    trailPos.y = (fract(8.0 * trailPos.y) - 0.5)/8.0;
    float trail = 1.0 - smoothstep(0.01, 0.03, length(trailPos));
    float fogTrail = smoothstep(-0.05, 0.05, dropPos.y);
    fogTrail *= 1.0 - smoothstep(y, 0.5, gv.y);
    trail *= fogTrail;
    fogTrail *= 1.0 - smoothstep(0.04, 0.05, abs(dropPos.x));
    
    float2 offset = drop * dropPos + trail * trailPos;
    offset.y *= -1.0;
    
    float blur = BLUR * 7 * (1.0 - fogTrail);
    
    float2 texUV = pixPos.xy/res;
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    blur *= 0.01;
    const float numSamples = 32;
    float a = N21(pos) * 2.0 * M_PI_F;
    for (float i = 0.0; i < numSamples ; ++i) {
        float2 sampleOffset = blur * float2(sin(a), cos(a));
        float d = N11((i + 1.0) * 546.0);
        d = sqrt(d);
        sampleOffset *= d;
        col += texture.sample(s, texUV + sampleOffset + DISTORTION * offset);
        ++a;
    }
    col /= numSamples;
    
    return col;
}

