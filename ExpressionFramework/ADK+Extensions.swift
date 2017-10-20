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
        var textColor = UIColor.black
        


        if let attributedText = dictionary["attributedText"] as? [String:AnyObject], let text = attributedText["text"] as? String{
            
            if let color = attributedText["color"] as? String {
                textColor = UIColor(hex: color) ?? .black
            }
            
            self.attributedText = text.attributedString(withFont:
                .systemFont(ofSize: attributedText["size"] as? CGFloat ?? 0,
                            weight: (attributedText["weight"] as? CGFloat).map { UIFont.Weight(rawValue: $0) } ?? .regular),
                        textColor:textColor)
            self.attributedText = NSAttributedString(attributedText)
        }
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

extension ButtonNode {
    convenience init( _ dictionary:[String:AnyObject]) {
        self.init()
        if let attributedText = dictionary["attributedText"] as? [String:AnyObject] {
            self.setAttributedTitle(NSAttributedString(attributedText), for: [])
        }
    }
}
