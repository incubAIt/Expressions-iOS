//
//  SpecProtocol.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 07/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol SpecProtocol {
    
    var object:AnyObject {get}
    var spec:ASLayoutSpec? {get}
    var internalActionHandler: ((_ actionId: String) -> Void)? { get }
}

extension SpecProtocol {
    
    var node:ASLayoutElement? {
        guard let spec = object["spec"] as? [String:AnyObject] else {
            return nil
        }
        guard let type = spec["type"] as? String else {
            return nil
        }
        switch type {
        case "stack":
            return ASStackLayoutSpec.with(spec, internalActionHandler: internalActionHandler)
        case "textNode":
            return ASTextNode.init(spec)
        case "networkImageNode":
            return ASNetworkImageNode.init(spec)
        case "displayNode":
            return ASDisplayNode()
        case "buttonNode":
            let buttonNode = ButtonNode.init(spec)
            let internalActionHandler = self.internalActionHandler
            buttonNode.touchUpAction = { actionId in
                internalActionHandler?(actionId)
            }
            return buttonNode
        default:
            return nil
        }
    }
    
    var cornerRadius:CGFloat? {
        return object["cornerRadius"] as? CGFloat
    }
    
    var insets:UIEdgeInsets {
        
        if let insets = object["insets"] as? [String:CGFloat] {
            return UIEdgeInsets(dictionary: insets)
        }
        return .zero
    }
    
    var overlay:ASLayoutSpec? {
        
        guard let object = object as? [String:AnyObject] else {
            return nil
        }
        if let overlay = object["overlay"] {
            return Spec(object: overlay as AnyObject, internalActionHandler: internalActionHandler).spec
        }
        return nil
    }
    
    var background:ASLayoutSpec? {
        
        guard let object = object as? [String:AnyObject] else {
            return nil
        }
        if let overlay = object["background"] {
            return Spec(object: overlay as AnyObject, internalActionHandler: internalActionHandler).spec
        }
        return nil
    }
    
    
    var spec:ASLayoutSpec? {
        
        let node = self.node
        
        if let node = node as? ASDisplayNode {
            node.backgroundColor = backgroundColor
            
            if let cornerRadius = cornerRadius {
                node.cornerRadius = cornerRadius
            }
            if let shadow = object["shadow"] as? [String:AnyObject] {
                node.applyShadow(shadow)
            }
        }
        
        if let height = object["height"] as? CGFloat {
            node?.style.height = ASDimensionMake(height)
        }
        
        if let width = object["width"] as? CGFloat {
            node?.style.width = ASDimensionMake(width)
        }
        
        var layout:ASLayoutElement? = node
        
        if let overlay = overlay {
            layout = layout?.overlayed(overlay)
        }
        
        if let background = background {
            layout = layout?.backgrounded(background)
        }
        
        
        return layout?.insetted(insets)
    }
    
    var backgroundColor:UIColor? {
        
        if let color = object["backgroundColor"] as? String {
            return UIColor(hex:color)
        }
        return nil
    }
    
}
