//
//  CollectionNodeSacaza.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 24/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

// MARK:- DataSource

public protocol SacazaCollectionNodeDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode
}

// MARK:- Delegate

public protocol SacazaCollectionNodeDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath)
}

// MARK:- class Declaration

public final class CollectionNodeSacaza: NSObject {
    
    var dataSource: SacazaCollectionNodeDataSource?
    var delegate: SacazaCollectionNodeDelegate?
    private weak var collectionNode: ASCollectionNode?
    private let sacaza: Sacaza
    
    public init(collectionNode: ASCollectionNode?, sacaza: Sacaza? = nil) {
        
        self.collectionNode = collectionNode
        self.sacaza = sacaza ?? Sacaza(sacazaAPI: SacazaAPI())
        super.init()
        self.collectionNode?.dataSource = self
    }
    
    public func reloadData() {
        guard let collectionNode = self.collectionNode else {
            return
        }
        if
            let sections = dataSource?.numberOfSections(in: collectionNode), // TODO handle multiple sections
            let items = dataSource?.collectionNode(collectionNode, numberOfItemsInSection: 0) {
            
            sacaza.reloadData(withNumberOfOriginalItems: items)
        }
        collectionNode.reloadData()
    }
    
    public func insertItems(insertions: [IndexPath], deletions: [IndexPath]) {
        
        let adjustedValues = sacaza.insertItems(insertions: insertions, deletions: deletions)
        
        collectionNode?.performBatchUpdates({
            collectionNode?.insertItems(at: adjustedValues.adjustedInsertions)
            collectionNode?.deleteItems(at: adjustedValues.adjustedDeletions)
        }, completion: nil)
    }
}

extension CollectionNodeSacaza: ASCollectionDataSource {
    
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return sacaza.totalNumberOfItems
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        guard let presenceItem = sacaza.presenceItem(at: indexPath) else {
            if let originalItemIndexPath = sacaza.calculateOriginalIndexPath(forItemAt: indexPath) {
                return dataSource?.collectionNode(collectionNode, nodeForItemAt: originalItemIndexPath) ?? ASCellNode()
            } else {
                return ASCellNode()
            }
        }
        return presenceItem.expression?.cellNode ?? ASCellNode()
    }
}

extension CollectionNodeSacaza: ASCollectionDelegate {
    
    public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        guard let originalIndexPath = sacaza.calculateOriginalIndexPath(forItemAt: indexPath) else {
            return
        }
        
        delegate?.collectionNode(collectionNode, didSelectItemAt: originalIndexPath)
    }
}
