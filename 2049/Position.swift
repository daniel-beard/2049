//
//  Position.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

public struct Position {
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
    
    public func equals(_ right: Position) -> Bool {
        return self == right
    }
}

//MARK: Custom operators
func == (left: Position, right: Position) -> Bool {
    return left.x == right.x && left.y == right.y
}

public enum TransitionType: String {
    case Unknown = "Unknown"
    case Moved = "Moved"
    case Added = "Added"
    case Removed = "Removed"
}

public struct PositionTransition : CustomStringConvertible, CustomDebugStringConvertible, Equatable {
    let start: Position
    let end: Position
    let type: TransitionType
    
    public var description: String {
        return "(\(start.x), \(start.y)) -> (\(end.x), \(end.y)) type: \(type.rawValue)\n"
    }
    
    public var debugDescription: String {
        return description
    }
}

public func == (left: PositionTransition, right: PositionTransition) -> Bool {
    return (left.start.x == right.start.x && left.end.y == right.end.y);
}
