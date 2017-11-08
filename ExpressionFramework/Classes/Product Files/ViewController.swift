//
//  ViewController.swift
//  ExpressionFramework
//
//  Created by Andriusstep on 18/10/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class CellNode:ASCellNode { // TODO why does this exist?
    
    
}

class APIRequest { // TODO move into its own file
    
    static func getListings(completion: @escaping (Result<[Listing], Void>) -> Void) {
        URLSession.expression.dataTask(with: ExpressionConfig.url.url!) { data, response, error in
            guard
                let arrayOfListingDictionaries = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String: AnyObject]]
                else {
                    DispatchQueue.main.async {
                        completion(.error(()))
                    }
                    return
            }
            let listings: [Listing] = arrayOfListingDictionaries.flatMap{ Listing(jsonDictionary: $0) }
            
            DispatchQueue.main.async {
                completion(.success(listings))
            }
        }.resume()
    }
}

class Listing {
    
    var id:String = "unknown"
    var expression: Expression? = nil // TODO it isnt great architecture to store visual behaviour within the data
    
    convenience init?(jsonDictionary: [String: AnyObject]) {
        guard let identifier = jsonDictionary["id"] as? String else {
            return nil
        }
        self.init()
        if let presentationDictionary = jsonDictionary["presentation"] {
            self.expression = Expression(contextId: identifier, object: presentationDictionary)
        }
        
        self.id = identifier
    }
}


class ViewController: ASViewController<ASCollectionNode> {
    
    var listings:[Listing] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red:239/255.0, green:239/255.0, blue:244/255.0, alpha: 1)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }

    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }
    
    @objc func refresh() {

        APIRequest.getListings() { [weak self] result in
            switch result {
            case .success(let listings):
                self?.listings = listings
                self?.node.reloadData()
            case .error: break
            }
        }
    }
    
    private func cellActionHandler(withActionId actionId: String, contextId: String, actionInfo: [AnyHashable: Any]) {
        
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
        return listings.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [weak self] in
            
            guard let listings = self?.listings else {
                return ASCellNode()
            }
            let listing = listings[indexPath.row]
            listing.expression?.actionHandler = self?.cellActionHandler
            return listing.expression?.cellNode ?? ASCellNode()
        }
    }
}

extension ViewController:ASCollectionDelegate {
    
}
