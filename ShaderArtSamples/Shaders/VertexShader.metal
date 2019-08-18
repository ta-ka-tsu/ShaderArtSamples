//
//  VertexShader.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/12.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

vertex float4 vertexShader(unsigned int vid [[ vertex_id ]])
{
    const float4x4 vertices = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ),
                                       float4(  1.0, -1.0, 0.0, 1.0 ),
                                       float4( -1.0,  1.0, 0.0, 1.0 ),
                                       float4(  1.0,  1.0, 0.0, 1.0 ));
    return vertices[vid];
}
