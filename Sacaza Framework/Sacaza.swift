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
    
    private var downloadedPresenceItems: [PresenceInfo] = [] // contains the adjusted index paths
    private var insertedPresenceItems: [PresenceInfo] = []   // contains the adjusted index paths
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
    
    func calculateAdjustedIndexPath(forItemAtOriginalIndexPath indexPath: IndexPath) -> IndexPath {
        
        for (index, info) in insertedPresenceItems.enumerated() {
            let adjustedIndex = indexPath.row + index
            
            if adjustedIndex < info.indexPath.row {
                return indexPathGenerator(for: indexPath, previousPresenceItems: index, offsetType: .adjusted)
            } else if adjustedIndex == info.indexPath.row {
                return indexPathGenerator(for: indexPath, previousPresenceItems: index + 1, offsetType: .adjusted)
            }
        }
        
        return indexPathGenerator(for: indexPath, previousPresenceItems: insertedPresenceItems.count, offsetType: .adjusted)
    }
}

// MARK:- Insertions / Deletions

extension Sacaza {
    
    func insertItems(insertions: [IndexPath], deletions: [IndexPath]) -> (adjustedInsertions: [IndexPath], adjustedDeletions: [IndexPath]) {
        
        let adjustedInsertions = insertions.map({return calculateAdjustedIndexPath(forItemAtOriginalIndexPath: $0)})
        let adjustedDeletions = deletions.map({return calculateAdjustedIndexPath(forItemAtOriginalIndexPath: $0)})
        
        enum AdjustmentType {
            case deletion
            case insertion
        }
        
        let generateArray: (AdjustmentType, [IndexPath]?) -> [PresenceInfo] = { adjustmentType, adjustments in
            
            guard let adjustments = adjustments else {
                return []
            }
            
            // loop through adjustments until we find the values we need
            var updatedPresenceItems: [PresenceInfo] = []
            var startingIndex = 0
            var amountToIncrement = 0
            for indexPath in adjustments {
                
                // loop through each value
                for index in startingIndex..<self.insertedPresenceItems.count {
                    
                    let info = self.insertedPresenceItems[index]
                    if info.indexPath.row >= indexPath.row {
                        amountToIncrement += 1
                        break
                    }
                    
                    if amountToIncrement > 0 {
                        let updatedPresenceInfo =  PresenceInfo(indexPath: IndexPath(row: info.indexPath.row + (adjustmentType == .insertion ? amountToIncrement : -amountToIncrement), section: info.indexPath.section), expressionContainer: info.expressionContainer)
                        updatedPresenceItems.append(updatedPresenceInfo)
                    }
                    
                    startingIndex += 1
                }
            }
            
            // finalise any uncommitted changes
            for index in startingIndex..<self.insertedPresenceItems.count {
                
                let info = self.insertedPresenceItems[index]
                let updatedPresenceInfo =  PresenceInfo(indexPath: IndexPath(row: info.indexPath.row + (adjustmentType == .insertion ? amountToIncrement : -amountToIncrement), section: info.indexPath.section), expressionContainer: info.expressionContainer)
                updatedPresenceItems.append(updatedPresenceInfo)
            }
            
            return updatedPresenceItems
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
        numberOfOriginalItems += adjustedInsertions.count - adjustedDeletions.count
        insertedPresenceItems = updatedInsertedPresenceItems
        return (adjustedInsertions, adjustedDeletions)
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
    private weak var collectionNode: ASCollectionNode?
    private let sacaza: Sacaza
    
    public init(collectionNode: ASCollectionNode?, dataSource: SacazaCollectionNodeDataSource, delegate: SacazaCollectionNodeDelegate, sacaza: Sacaza? = nil) {
        
        self.collectionNode = collectionNode
        self.dataSource = dataSource
        self.delegate = delegate
        self.sacaza = sacaza ?? Sacaza()
        super.init()
        self.collectionNode?.dataSource = self
    }
    
    public func reloadData() {
        guard let collectionNode = self.collectionNode else {
            return
        }
        let sections = dataSource.numberOfSections(in: collectionNode)
        let items = dataSource.collectionNode(collectionNode, numberOfItemsInSection: 0)
        
        sacaza.reloadData(withNumberOfOriginalItems: items)  // TODO handle multiple sections
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

