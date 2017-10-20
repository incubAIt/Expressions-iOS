//
//  String+Extensions.swift
//  ExpressionFramework
//
//  Created by Andriusstep on 18/10/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    var url:URL? {
        return URL(string:self)
    }
    
    var trimed:String {
        
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.lowerBound, within: utf16view)!.encodedOffset
        let to = String.UTF16View.Index(range.upperBound, within: utf16view)!.encodedOffset
        return NSMakeRange(from - utf16view.startIndex.encodedOffset, to - from)
    }
    
    var bool:Bool? {
        switch self {
        case "YES":
            return true
        case "NO":
            return false
        default:
            return nil
        }
    }
    
    var urlParam:String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    
    
    func mutableAttributedString(withFont:UIFont, image:UIImage?=nil, textColor:UIColor?=nil, lineSpacing:CGFloat?=nil, textAlignment:NSTextAlignment?=nil, lineBreakMode:NSLineBreakMode? = nil) -> NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: self.attributedString(withFont: withFont, image:image, textColor: textColor, lineSpacing: lineSpacing, textAlignment: textAlignment, lineBreakMode: lineBreakMode))
    }
    
    func attributedString(withFont:UIFont, image:UIImage?=nil, textColor:UIColor?=nil, lineSpacing:CGFloat?=nil, textAlignment:NSTextAlignment?=nil, lineBreakMode:NSLineBreakMode? = nil) -> NSAttributedString {
        var attributes:[NSAttributedStringKey:Any] = [NSAttributedStringKey.font:withFont]
        if let textColor  = textColor {
            attributes[NSAttributedStringKey.foregroundColor] = textColor
        }
        if lineSpacing != 0 || textAlignment != nil || lineBreakMode != nil {
            let style = NSMutableParagraphStyle()
            if let lineBreakMode = lineBreakMode {
                style.lineBreakMode = lineBreakMode
            }
            if let textAlignment = textAlignment {
                style.alignment = textAlignment
            }
            if let lineSpacing = lineSpacing {
                style.lineSpacing = lineSpacing
            }
            attributes[NSAttributedStringKey.paragraphStyle] = style
            
        }
        let attributedString = NSMutableAttributedString(string: self, attributes: attributes)
        
        if let image = image {
            let attachment = NSTextAttachment()
            
            let imageGap = (image.size.height-withFont.lineHeight)
            
            attachment.bounds = CGRect(x:0, y:-imageGap,width:image.size.width, height:image.size.height)
            attachment.image = image
            let string = NSAttributedString(attachment: attachment)
            
            attributedString.replaceCharacters(in: NSMakeRange(0, 0), with: "  ")
            attributedString.replaceCharacters(in: NSMakeRange(0, 0), with:string)
            
        }
        return attributedString
    }
}

extension NSAttributedString {
    
    convenience init?(_ dictionary:[String:AnyObject]) {
        
        if let text = dictionary["text"] as? String{
            var textColor = UIColor.black
            
            if let color = dictionary["color"] as? String {
                textColor = UIColor(hex: color) ?? .black
            }

            self.init(attributedString: text.attributedString(withFont:
                .systemFont(ofSize: dictionary["size"] as? CGFloat ?? 0,
                            weight: (dictionary["weight"] as? CGFloat).map { UIFont.Weight(rawValue: $0) } ?? .regular),
                                                        textColor:textColor))
            return
        }
        
        return nil
    }
}
