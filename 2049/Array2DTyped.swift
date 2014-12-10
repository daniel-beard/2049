//
//  Array2DTyped.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

class Array2DTyped<T>{
    
    var cols:Int, rows:Int
    var matrix:[T]
    
    init(cols:Int, rows:Int, defaultValue:T){
        self.cols = cols
        self.rows = rows
        matrix = Array(count:cols*rows,repeatedValue:defaultValue)
    }
    
    subscript(col:Int, row:Int) -> T {
        get{
            return matrix[cols * row + col]
        }
        set{
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