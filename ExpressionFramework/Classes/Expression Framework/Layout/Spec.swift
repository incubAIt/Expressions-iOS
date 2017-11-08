//
//  Spec.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 07/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation

struct Spec:SpecProtocol {
    
    var object:AnyObject
    
    var internalActionHandler: ((String) -> Void)?
}
