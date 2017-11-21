//
//  Array+SafeIndex.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 21/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation

public extension Array
{
    subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
}
