//
//  ViewController.swift
//  ExpressionFramework
//
//  Created by Andriusstep on 18/10/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import UIKit
import AsyncDisplayKit


class CellNode:ASCellNode {
    
    
}

extension URLSession {
    
    static var expression:URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }
}

struct Expression:BackgroundDecoratedProtocol {
    
    var object:AnyObject
}

extension Expression: SpecProtocol {
    

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
        
        if let width = width {
            node.style.width = ASDimensionMake(width)
        }
        

        if let spec = spec {
            node.automaticallyManagesSubnodes = true
            node.layoutSpecBlock = { _, _ in
                return spec
            }
        }
        node.backgroundColor = .orange
        
        return node
    }
}
protocol SpecProtocol {
    
    var object:AnyObject {get}
    var spec:ASLayoutSpec? {get}
}

struct Spec:SpecProtocol {
    
    var object:AnyObject
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
            return ASStackLayoutSpec.with(spec)
        case "textNode":
            return ASTextNode.init(spec)
        case "imageNode":
            return ASNetworkImageNode.init(spec)
        case "displayNode":
            return ASDisplayNode()
        case "buttonNode":
            return ButtonNode.init(spec)
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
            return Spec(object: overlay as AnyObject).spec
        }
        return nil
    }
    
    var background:ASLayoutSpec? {
        
        guard let object = object as? [String:AnyObject] else {
            return nil
        }
        if let overlay = object["background"] {
            return Spec(object: overlay as AnyObject).spec
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

extension ASStackLayoutSpec {
    
    static func with(_ dictionary:[String:AnyObject]) -> ASStackLayoutSpec? {
        
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
        
        if let children = dictionary["children"] as? [[String:AnyObject]] {
            
            children.map { Spec.init(object: $0 as AnyObject) }.flatMap { $0.spec }.forEach {
                spec.children?.append($0)
            }
        }
        
        return spec
    }
}


protocol BackgroundDecoratedProtocol {
    
    var object:AnyObject {get}
}




class ViewController: ASViewController<ASCollectionNode> {
    
    var expression:Expression? {
        didSet{
            DispatchQueue.main.async {
                self.node.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }

    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }
    
    @objc func refresh() {

        URLSession.expression.dataTask(with: "http://macbook-pro.local:8000/1.json".url!) { data, response, error in
            self.expression = Expression(object: try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject)
        }.resume()
    }
}

extension ViewController {
    
    
    convenience init () {
        let node = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
        self.init(node: node)
        node.delegate = self
        node.dataSource = self
    }
}

extension ViewController:ASCollectionDataSource {
    

    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        return expression?.cellNode ?? ASCellNode()
    }

}

extension ViewController:ASCollectionDelegate {
    
}
