//
//  Expression.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 07/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation
import AsyncDisplayKit

public typealias ActionHandler = ((_ actionId: String, _ contextId: String, _ actionInfo: [AnyHashable: Any]) -> Void)?

public struct Expression:BackgroundDecoratedProtocol {
    public let contextId: String
    public let object:[AnyHashable: AnyObject]
    public var actionHandler: ActionHandler? = nil // This should only be set within the presentation layer
    
    public init(contextId: String, object:[AnyHashable: AnyObject]) {
        self.contextId = contextId
        self.object = object
    }
}

extension Expression: SpecProtocol {
    
    internal var internalActionHandler: ((String) -> Void)? { get {
        let actionHandler = self.actionHandler
        let contextId = self.contextId
            return { actionId in
                guard let handler = actionHandler else {
                    return
                }
                handler?(actionId, contextId, [:])
            }
        }
    }
    
    var height:CGFloat? {
        return object["height"] as? CGFloat
    }
    
    var width:CGFloat? {
        return object["width"] as? CGFloat
    }
    
    public var cellNode:ASCellNode {
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
