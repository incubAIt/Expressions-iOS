//
//  Advert.swift
//  Expression
//
//  Created by Matt Harding on 14/11/2017.
//

import Foundation

public struct Advert {
    
    var id:String = "unknown"
    var expression: Expression? = nil
    
}

extension Advert {
    
    init?(jsonDictionary: [String: AnyObject]) {
        guard let identifier = jsonDictionary["id"] as? String else {
            return nil
        }
        
        self.init()
        
        if let presentationDictionary = jsonDictionary["expression"] as? [AnyHashable: AnyObject] {
            self.expression = Expression(contextId: identifier, object: presentationDictionary)
        }
        
        self.id = identifier
    }
}

