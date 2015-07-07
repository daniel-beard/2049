//
//  Array2DOptional.swift
//  2049
//
//  Created by Daniel Beard on 7/5/15.
//  Copyright © 2015 DanielBeard. All rights reserved.
//

import Foundation

import Foundation

class Array2DOptional<T> {
    
    var cols:Int, rows:Int
    var matrix:[T?]
    
    init(cols:Int, rows:Int, defaultValue:T?) {
        self.cols = cols
        self.rows = rows
        matrix = Array(count:cols*rows, repeatedValue:defaultValue)
    }
    
    subscript(col:Int, row:Int) -> T? {
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
}