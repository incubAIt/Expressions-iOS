//
//  UIEdgeInsets+Extensions.swift
//  ExpressionFramework
//
//  Created by Andriusstep on 19/10/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation
import UIKit

public typealias InsetDimension = CGFloat
extension UIEdgeInsets {
    
    init(dictionary:[String:InsetDimension]) {
        self.init(
            top: dictionary["top"]?.value ?? 0,
            left: dictionary["left"]?.value ?? 0,
            bottom: dictionary["bottom"]?.value ?? 0,
            right: dictionary["right"]?.value ?? 0)
    }
}


extension InsetDimension {
    
    var value:InsetDimension {
        if self == -1 {
            return .infinity
        }
        return self
    }
}
