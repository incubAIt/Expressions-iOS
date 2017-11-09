//
//  ADK+Extensions.swift
//  hyperlocalNews
//
//  Created by Andriusstep on 10/10/2017.
//  Copyright © 2017 Andrius Steponavicius. All rights reserved.
//

import Foundation
import AsyncDisplayKit

extension ASLayoutElement {
    
    func insetted(_ edges:UIEdgeInsets) -> ASLayoutSpec {

        return ASInsetLayoutSpec(insets: edges, child: self)
    }
    
    func overlayed(_ element:ASLayoutElement) -> ASLayoutSpec {
        
        return ASOverlayLayoutSpec(child: self, overlay: element)
    }
    
    func backgrounded(_ element:ASLayoutElement) -> ASLayoutElement {
        return ASBackgroundLayoutSpec(child: self, background: element)
    }
}

extension UIEdgeInsets {
    static var `default`:UIEdgeInsets { return UIEdgeInsetsMake(0, 15, 0, 15)}
    
}

extension  ASDisplayNode {
    
    func with(backgroundColor:UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    func with(height:CGFloat) -> Self {
        self.style.height = ASDimensionMake(height)
        return self
    }
}

extension ASDisplayNode {
    
    func applyShadow(_ dictionary:[String:AnyObject]) {
        
        if let radius = dictionary["radius"] as? CGFloat {
            
            self.shadowRadius = radius
        }
        
        if let opacity = dictionary["opacity"] as? CGFloat {
            
            self.shadowOpacity = opacity
        }
        
        if let offset = dictionary["offset"] as? [String:CGFloat] {
            
            self.shadowOffset = CGSize(offset)
        }
        
        if let color = dictionary["color"] as? String {
            self.shadowColor = UIColor(hex: color)?.cgColor
        }
        
    }
}

extension CGSize {
    
    init(_ dictionary:[String:CGFloat]) {
        self.init(width: dictionary["x"] ?? 0, height: dictionary["y"] ?? 0)
    }
}

extension ASTextNode {
    
    convenience init( _ dictionary:[String:AnyObject]) {
        self.init()
        
        self.attributedText = attributedText(forExpressionDictionary: dictionary)
        
        if let insets = dictionary["insets"] as? [String:CGFloat] {
            self.textContainerInset = UIEdgeInsets.init(dictionary: insets)
        }
        self.clipsToBounds = true
    }
    
    private func attributedText(forExpressionDictionary expressionDictionary: [String:AnyObject]) -> NSAttributedString? {
        
        guard let attributedTextSegments = expressionDictionary["attributedText"] as? [[String:AnyObject]] else {
            return nil
        }
            
        let tempAttributedText = NSMutableAttributedString()
        for segment in attributedTextSegments {
            
            let text: String? = {
                
                if let deviceInputType = segment["deviceInputType"] as? String {
                    return self.calculateText(forDeviceInputType: deviceInputType, expressionAttributes: segment)
                }
                return segment["text"] as? String
            }()
            
            if let text = text {
                tempAttributedText.append(attributedText(for: text, expressionAttributes: segment))
            }
        }
        return tempAttributedText
    }
    
    private func attributedText(for text: String, expressionAttributes: [String:AnyObject]) -> NSAttributedString {
        
        let textColor: UIColor = {
            guard
                let color = expressionAttributes["color"] as? String,
                let textColor = UIColor(hex: color)
                else {
                return UIColor.black
            }
            return textColor
        }()
        
        return text.attributedString(withFont:
                .systemFont(ofSize: expressionAttributes["size"] as? CGFloat ?? 0,
                            weight: (expressionAttributes["weight"] as? CGFloat).map { UIFont.Weight(rawValue: $0) } ?? .regular),
                                                        textColor:textColor)
    }
    
    private func calculateText(forDeviceInputType deviceInputType: String, expressionAttributes: [String:AnyObject]) -> String? {
        
        let value = expressionAttributes["value"]
        switch deviceInputType {
        case "date-ago":
            if let secondsAgo = value as? Int {
                return secondsAgo.timeAgoString
            }
            
        case "date":
            if let secondsAgo = value as? Int {
                return secondsAgo.timeStamp
            }
        default: break
        }
        return nil
    }
}

extension ASNetworkImageNode {
    
    convenience init( _ dictionary:[String:AnyObject]) {
        self.init()
        if let url = dictionary["imageUrl"] as? String {
            self.setURL(url.url, resetToDefault: true)
        }

    }
}

extension ASStackLayoutSpec {
    
    static func with(_ dictionary:[String:AnyObject], internalActionHandler: ((_ actionId: String) -> Void)?) -> ASStackLayoutSpec? {
        
        guard let orientation = dictionary["orientation"]  as? String else {
            return nil
        }
        
        var spec:ASStackLayoutSpec!
        
        switch orientation {
        case "vertical":
            spec = vertical()
            break
        case "horizontal":
            spec = horizontal()
            break
        default:
            return nil
        }
        
        spec.spacing = dictionary["spacing"]  as? CGFloat ?? 0
//        spec.alignContent = .spaceBetween
        if let children = dictionary["children"] as? [[String:AnyObject]] {
            
            children.map { Spec.init(object: $0 as AnyObject, internalActionHandler: internalActionHandler) }.flatMap { $0.spec }.forEach {
                spec.children?.append($0)
            }
        }
        
        
        
        return spec
    }
}
