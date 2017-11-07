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
        self.view.backgroundColor = UIColor(red:239/255.0, green:239/255.0, blue:244/255.0, alpha: 1)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }

    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }
    
    @objc func refresh() {

        URLSession.expression.dataTask(with: ExpressionConfig.url.url!) { [weak self] data, response, error in
            let jsonDict = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
            self?.expression = Expression(contextId: "234567890", object: jsonDict, actionHandler: self?.cellRequestsAction)
        }.resume()
    }
    
    private func cellRequestsAction(withActionId actionId: String, contextId: String, actionInfo: [AnyHashable: Any]) {
        
        switch actionId {
        case "share": break // inspect action Info for more details
        case "report": break
        default: break
        }
    }
}

extension ViewController {
    
    
    convenience init () {
        let node = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
        node.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
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
        return 200
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            return self.expression?.cellNode ?? ASCellNode()
        }
    }
}

extension ViewController:ASCollectionDelegate {
    
}
