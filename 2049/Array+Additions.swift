//
//  Array+Additions.swift
//  GrouponMaps
//
//  Created by Daniel Beard on 12/9/14.
//  Copyright (c) 2014 Andrey Yegorov. All rights reserved.
//

import Foundation

extension Array {
    func each(each: (T) -> ()) {
        for object: T in self {
            each(object)
        }
    }
}
