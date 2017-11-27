//
//  PresenceItem.swift
//  Expression
//
//  Created by Matt Harding on 14/11/2017.
//

import Foundation

public struct PresenceItem: ExpressionRepresentable {
    
    var identifier:String
    public var expression: Expression?
}

extension PresenceItem {
    
    init?(jsonDictionary: [String: AnyObject]) {
        
        guard
            let identifier = jsonDictionary["id"] as? String,
            let presentationDictionary = jsonDictionary["expression"] as? [AnyHashable: AnyObject] else {
            return nil
        }
        
        let expression = Expression(contextId: identifier, object: presentationDictionary)
        self.init(identifier: identifier, expression: expression)
    }
}

