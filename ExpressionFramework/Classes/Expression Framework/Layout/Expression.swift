//
//  Expression.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 07/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation
import AsyncDisplayKit

typealias ActionHandler = ((_ actionId: String, _ contextId: String, _ actionInfo: [AnyHashable: Any]) -> Void)?

struct Expression:BackgroundDecoratedProtocol {
    var contextId: String
    var object:AnyObject
    var actionHandler: ActionHandler
    
    init(contextId: String, object:AnyObject, actionHandler: ActionHandler) {
        self.contextId = contextId
        self.object = object
        self.actionHandler = actionHandler
    }
}

extension Expression: SpecProtocol {
    
    var internalActionHandler: ((String) -> Void)? { get {
        
            return { actionId in
                self.actionHandler?(actionId, self.contextId, [:])
            }
        }
    }
    
    var height:CGFloat? {
        return object["height"] as? CGFloat
    }
    
    var width:CGFloat? {
        return object["width"] as? CGFloat
    }
    
    
    var cellNode:ASCellNode {
        let node = ASCellNode()
        
        if let height = height {
            node.style.height = ASDimensionMake(height)
        }
        
        node.backgroundColor = .clear
        
        if let width = width {
            node.style.width = ASDimensionMake(width)
        }
        
        if let spec = spec {
            node.automaticallyManagesSubnodes = true
            node.layoutSpecBlock = { _, _ in
                return spec
            }
        }
        return node
    }
}
