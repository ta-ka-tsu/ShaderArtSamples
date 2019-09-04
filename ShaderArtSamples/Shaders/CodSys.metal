//
//  CodSys.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/09/03.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

// 画面中心原点の座標系(X方向右向き、Y方向上向き-1〜1)
fragment float4 CodSys1(float4 pixPos [[position]],
                        constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    return step(length(uv), 1.0);
}

// 画面左下原点の座標系(Y方向上向き0〜1)
fragment float4 CodSys2(float4 pixPos [[position]],
                        constant float2& res[[buffer(0)]])
{
    float2 uv = (pixPos.xy - float2(0.0, res.y))/min(res.x, res.y);
    uv.y *= -1.0;
    return step(length(uv), 1.0);
}
