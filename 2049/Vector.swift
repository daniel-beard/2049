//
//  Vector.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

open class Vector {
    var x = 0
    var y = 0
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    open class func getVector(_ direction: Int) -> Vector {
        let map: [Int: Vector] = [
            0: Vector(x: 0, y: -1), // Up
            1: Vector(x: 1, y: 0),  // Right
            2: Vector(x: 0, y: 1),  // Down
            3: Vector(x: -1, y: 0)  // Left
        ]
        return map[direction]!
    }
}
