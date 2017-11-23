//
//  Sacaza.swift
//  Expression
//
//  Created by Matt Harding on 14/11/2017.
//

import Foundation
import UIKit
import AsyncDisplayKit

//public protocol SacazaDelegate {
//    func sacazaDidFailToDownloadAdverts()
//    func sacazaDidDownloadAdverts(_ adverts: [Advert])
//}
//
//public class Sacaza {
//
//    public var adverts: [Advert] = []
//    public var hasDownloadedPresenceItems: Bool {
//        return adverts.count > 0
//    }
//
//    public var delegate: SacazaDelegate?
////    public var collectionNodeDataSource: SacazaCollectionNodeDataSource?
//    public init() {
//
//    }
//
//    public func start() {
//
//        APIRequest.getAdverts() { result in
//            switch result {
//            case .success(let adverts):
//                self.adverts = adverts
//                // TODO cache the adverts that have been downloaded then decide when to distribute them
//                self.delegate?.sacazaDidDownloadAdverts(adverts)
//            case .error:
//                self.delegate?.sacazaDidFailToDownloadAdverts()
//            }
//        }
//    }
//}

public struct PresenceInfo {
    let indexPath: IndexPath
    let expressionContainer: ExpressionRepresentable
}

// MARK:- Testability

extension Sacaza {
    
    convenience init(presenceItems: [PresenceInfo], numberOfOriginalItems: Int) {
        self.init()
        self.downloadedPresenceItems = presenceItems
        self.reloadData(withNumberOfOriginalItems: numberOfOriginalItems)
    }
}

// MARK:- Class Declaration

public final class Sacaza {
    
    private var downloadedPresenceItems: [PresenceInfo] = []
    private var insertedPresenceItems: [PresenceInfo] = []
    private var numberOfOriginalItems: Int = 0
    
    private var isRefreshing = false
    
    func reloadData(withNumberOfOriginalItems numberOfOriginalItems: Int) {
        self.numberOfOriginalItems = numberOfOriginalItems
        insertedPresenceItems = []
        mergePendingItems()
    }
    
    func refresh() {
        guard isRefreshing == false else {
            return
        }
        isRefreshing = true
        APIRequest.getPresenceItems() { result in
            self.isRefreshing = false
            switch result {
                case .success(let presenceItems):
                    self.downloadedPresenceItems = presenceItems
                    self.insertedPresenceItems = []
                    // TODO finish
                case .error:
                    // TODO finish
                break
            }
        }
    }
    
    fileprivate func mergePendingItems() {
        
        insertedPresenceItems = []
        
        downloadedPresenceItems.forEach { info in
            let numberOfTotalItems = numberOfOriginalItems + insertedPresenceItems.count
            if info.indexPath.row <= numberOfTotalItems {
                insertedPresenceItems.append(info)
            } else {
                return
            }
        }
    }
}

// MARK:- Querying The Datasource

extension Sacaza {
    
    fileprivate func indexOfPresenceItem(at indexPath: IndexPath) -> Int? {
        
        return insertedPresenceItems.index(where: { info in // TODO enhance with Binary Search
            if info.indexPath.row == indexPath.row && info.indexPath.section == indexPath.section {
                return true
            }
            return false
        })
    }
    
    fileprivate func isPresenceItem(at indexPath: IndexPath) -> Bool {
        
        guard let _ = indexOfPresenceItem(at: indexPath) else {
            return false
        }
        return true
    }
    
    fileprivate func presenceItem(at indexPath: IndexPath) -> ExpressionRepresentable? {
        
        guard let foundIndex = indexOfPresenceItem(at: indexPath) else {
            return nil
        }
        return insertedPresenceItems[safe: foundIndex]?.expressionContainer
    }
    
    var totalNumberOfItems: Int {
        return numberOfOriginalItems + insertedPresenceItems.count
    }
}

// MARK:- IndexPath Offsets

extension Sacaza {
    
    enum OffsetType {
        case original
        case adjusted
    }
    
    fileprivate func indexPathGenerator(for indexPath: IndexPath, previousPresenceItems: Int, offsetType: OffsetType) -> IndexPath {
        return IndexPath(row: indexPath.row + (offsetType == .original ? -previousPresenceItems : previousPresenceItems), section: indexPath.section)
    }
    
    fileprivate func calculateOriginalIndexPath(forItemAt indexPath: IndexPath) -> IndexPath? {
        
        for (index, info) in insertedPresenceItems.enumerated() {
            if info.indexPath == indexPath {
                return nil // it is an advert
            }
            
            if info.indexPath.row > indexPath.row {
                return indexPathGenerator(for: indexPath, previousPresenceItems: index, offsetType: .original)
            }
        }
        
        return indexPathGenerator(for: indexPath, previousPresenceItems: insertedPresenceItems.count, offsetType: .original)
    }
    
    fileprivate func calculateAdjustedIndexPath(forItemAtOriginalIndexPath indexPath: IndexPath) -> IndexPath {
        
        for (index, info) in insertedPresenceItems.enumerated() {
            
            if info.indexPath.row >= indexPath.row {
                return indexPathGenerator(for: indexPath, previousPresenceItems: index, offsetType: .adjusted)
            }
        }
        
        return indexPathGenerator(for: indexPath, previousPresenceItems: insertedPresenceItems.count, offsetType: .adjusted)
    }
}

// MARK:- Insertions / Deletions

extension Sacaza {
    
    func insertItems(insertions: [IndexPath], deletions: [IndexPath]) {
        
        let adjustedInsertions = insertions.map({return calculateAdjustedIndexPath(forItemAtOriginalIndexPath: $0)})
        let adjustedDeletions = deletions.map({return calculateAdjustedIndexPath(forItemAtOriginalIndexPath: $0)})
        
        // TODO we can inform the collection view of these changes
        
        enum AdjustmentType {
            case deletion
            case insertion
        }
        
        let generateArray: (AdjustmentType, [IndexPath]?) -> [PresenceInfo] = { adjustmentType, adjustments in
            
            guard let adjustments = adjustments else {
                return []
            }
            var newArray: [PresenceInfo] = []
            var amountToIncrement = 0
            var index = 0
            for info in self.insertedPresenceItems {
                
                if let indexPath = adjustments[safe: index] {
                    if info.indexPath.row >= indexPath.row {
                        amountToIncrement += 1
                        index += 1
                    }
                }
                let presenceInfo = PresenceInfo(indexPath: IndexPath(row: info.indexPath.row + (adjustmentType == .insertion ? amountToIncrement : -amountToIncrement), section: info.indexPath.section), expressionContainer: info.expressionContainer)
                newArray.append(presenceInfo)
            }
            return newArray
        }
        
        let amendmentsForInsertions: [PresenceInfo] = generateArray(.insertion, adjustedInsertions)
        let amendmentsForDeletions: [PresenceInfo] = generateArray(.deletion, adjustedDeletions)
        var updatedInsertedPresenceItems: [PresenceInfo] = []
        
        // compare arrays to remain in sync!
        for index in 0..<amendmentsForInsertions.count {
            guard
                let infoAfterInsertions = amendmentsForInsertions[safe: index],
                let infoAfterDeletions = amendmentsForDeletions[safe: index],
                let infoBeforeAmendments = insertedPresenceItems[safe: index] else {
                    fatalError()    // TODO shall we think of an alternative for production? If we are out of sync the UITableView will most likely throw an exception anyway
            }
            
            let differenceForInsertions = infoAfterInsertions.indexPath.row - infoBeforeAmendments.indexPath.row
            let differenceForDeletions = infoAfterDeletions.indexPath.row - infoBeforeAmendments.indexPath.row
            let newRow = infoBeforeAmendments.indexPath.row + differenceForInsertions + differenceForDeletions
            let presenceInfo = PresenceInfo(indexPath: IndexPath(row: newRow, section: infoBeforeAmendments.indexPath.section), expressionContainer:infoBeforeAmendments.expressionContainer)
            updatedInsertedPresenceItems.append(presenceInfo)
        }
        
        insertedPresenceItems = updatedInsertedPresenceItems
    }
}

// MARK:- ASCollectionNode Support

@objc public protocol SacazaCollectionNodeDataSource : NSObjectProtocol {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode
}

@objc public protocol SacazaCollectionNodeDelegate : NSObjectProtocol {
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath)
}

public final class CollectionNodeSacaza: NSObject {
    
    private let dataSource: SacazaCollectionNodeDataSource
    private let delegate: SacazaCollectionNodeDelegate
    private let collectionNode: ASCollectionNode
    private let sacaza: Sacaza
    
    public init(collectionNode: ASCollectionNode, dataSource: SacazaCollectionNodeDataSource, delegate: SacazaCollectionNodeDelegate, sacaza: Sacaza? = nil) {
        
        self.collectionNode = collectionNode
        self.dataSource = dataSource
        self.delegate = delegate
        self.sacaza = sacaza ?? Sacaza()
        super.init()
        collectionNode.dataSource = self
    }
    
    public func reloadData() {
        let sections = dataSource.numberOfSections(in: collectionNode)
        let items = dataSource.collectionNode(collectionNode, numberOfItemsInSection: 0)
        
        sacaza.reloadData(withNumberOfOriginalItems: items)  // TODO handle multiple sections
        collectionNode.reloadData()
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
                return dataSource.collectionNode(collectionNode, nodeForItemAt: originalItemIndexPath)
            } else {
                fatalError()
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
        
        delegate.collectionNode(collectionNode, didSelectItemAt: originalIndexPath)
    }
}

