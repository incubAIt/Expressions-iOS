//
//  ASCollectionNode+Sacaza.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 24/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

public extension ASCollectionNode {
    
    private struct AssociatedKeys {
        static var sacaza: UInt8 = 0
    }
    
    private (set) var sacaza: CollectionNodeSacaza? {
        get {
            guard let collectionNodeSacaza = objc_getAssociatedObject(self, &AssociatedKeys.sacaza) as? CollectionNodeSacaza else {
                let collectionNodeSacaza = CollectionNodeSacaza(collectionNode: self)
                self.sacaza = collectionNodeSacaza
                return collectionNodeSacaza
            }
            return collectionNodeSacaza
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.sacaza, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func sza_reloadData() {
        sacaza?.reloadData()
    }
    
    public func sza_insertItems(atIndexPaths indexpaths: [IndexPath]) {
        sacaza?.insertItems(insertions: indexpaths, deletions: [])
    }
    
    public func sza_deleteItems(atIndexPaths indexpaths: [IndexPath]) {
        sacaza?.insertItems(insertions: [], deletions: indexpaths)
    }
    
    public func sza_performBatchUpdates(withInsertionsAtIndexPaths insertions: [IndexPath], deletions: [IndexPath]) {
        sacaza?.insertItems(insertions: insertions, deletions:deletions)
    }
    
    public func sza_setDelegate(_ delegate: SacazaCollectionNodeDelegate) {
        sacaza?.delegate = delegate
    }
    
    public func sza_setDataSource(_ dataSource: SacazaCollectionNodeDataSource) {
        sacaza?.dataSource = dataSource
    }
}

