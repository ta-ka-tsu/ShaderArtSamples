//
//  Library.swift
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/03.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

import Foundation
import Metal


class Library {
    var device : MTLDevice!
    
    init() {
        device = MTLCreateSystemDefaultDevice()
    }
}

extension MTLLibrary {
    public var allFunctions : [MTLFunction] {
        return self.functionNames.compactMap { self.makeFunction(name: $0) }
    }
    
    public var allFragmentFunctions : [MTLFunction] {
        return self.allFunctions.filter { $0.functionType == .fragment }
    }
}
