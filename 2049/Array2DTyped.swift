//
//  Array2DTyped.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

class Array2DTyped<T> : Sequence, IteratorProtocol {
    
    var cols:Int, rows:Int
    var matrix:[T]
    
    init(cols:Int, rows:Int, defaultValue:T) {
        self.cols = cols
        self.rows = rows
        matrix = Array(repeating: defaultValue, count: cols*rows)
    }
    
    subscript(col:Int, row:Int) -> T {
        get {
            return matrix[cols * row + col]
        }
        set {
            matrix[cols * row + col] = newValue
        }
    }
    
    func colCount() -> Int {
        return self.cols
    }
    
    func rowCount() -> Int {
        return self.rows
    }
    
    //MARK: GeneratorType
    
    var currentElement = 0
    func next() -> T? {
        if currentElement < matrix.count {
            let curItem = currentElement
            currentElement += 1
            return matrix[curItem]
        }
        return nil
    }
    
    //MARK: SequenceType
    
    typealias Iterator = Array2DTyped
    
    func makeIterator() -> Iterator {
        return self
    }
}
