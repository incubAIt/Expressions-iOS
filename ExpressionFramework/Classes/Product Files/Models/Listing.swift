//
//  Listing.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 08/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation

class Listing: ExpressionRepresentable {
    
    var id:String = "unknown"
    var expression: Expression? = nil
    
    convenience init?(jsonDictionary: [String: AnyObject]) {
        guard let identifier = jsonDictionary["id"] as? String else {
            return nil
        }
        
        self.init()
        
        if let presentationDictionary = jsonDictionary["expression"] {
            self.expression = Expression(contextId: identifier, object: presentationDictionary)
        }
        
        self.id = identifier
    }
}
