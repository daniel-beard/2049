//
//  Position.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation



public class Position {
    var x = 0
    var y = 0
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init(position: Position) {
        x = position.x
        y = position.y
    }
    
    public func description() -> String {
        return "x: \(x) y: \(y)"
    }
    
    public func equals(right: Position) -> Bool {
        return self == right
    }
}

//MARK: Custom operators
func == (left: Position, right: Position) -> Bool {
    return left.x == right.x && left.y == right.y
}