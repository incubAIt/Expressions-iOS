//
//  Sacaza.swift
//  Expression
//
//  Created by Matt Harding on 14/11/2017.
//

import Foundation

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




struct TestableAdvert: ExpressionRepresentable {
    let text: String
    var expression: Expression? = nil
}

typealias PresenceInfo = (IndexPath, ExpressionRepresentable)

// MARK:- Testability

extension Sacaza {
    
    convenience init(presenceItems: [PresenceInfo], numberOfOiginalItems: Int) {
        self.init()
        self.insertedPresenceItems = presenceItems
        self.numberOfOiginalItems = numberOfOiginalItems
    }
}

class Sacaza {
    
    var pendingPresenceItems: [ExpressionRepresentable] = []
    var insertedPresenceItems: [PresenceInfo] = []
    var numberOfOiginalItems: Int = 0
    
    func start() {
        APIRequest.getPresenceItems() { result in
        switch result {
            case .success(let presenceItems):
                self.pendingPresenceItems = presenceItems
            
            case .error:
            break
            }
        }
    }
    
    func mergePendingItems() {
        
        var indexToInsert = 0
        let advertsWithIndexPaths: [PresenceInfo] = pendingPresenceItems.map({
            indexToInsert += 4  // TODO these indexes should be coming from the server
            return (IndexPath(row: indexToInsert, section: 0), $0)
        })
        
        advertsWithIndexPaths.forEach { info in
            let numberOfTotalItems = numberOfOiginalItems + insertedPresenceItems.count
            if info.0.row <= numberOfTotalItems {
                insertedPresenceItems.append(info)
            } else {
                return
            }
        }
    }
    
    func isItemAnAdvert(at indexPath: IndexPath) -> Bool {
        
        // find the indexpath in the feed
        let index = insertedPresenceItems.index(where: { info in // TODO enhance with Binary Search
            if info.0.row == indexPath.row && info.0.section == indexPath.section {
                return true
            }
            return false
        })
        
        guard let _ = index else {
            return false
        }
        return true
    }
    
    enum OffsetType {
        case original
        case adjusted
    }
}

// MARK:- IndexPath Offsets

extension Sacaza {
    
    fileprivate func indexPathGenerator(for indexPath: IndexPath, previousPresenceItems: Int, offsetType: OffsetType) -> IndexPath {
        return IndexPath(row: indexPath.row + (offsetType == .original ? -previousPresenceItems : previousPresenceItems), section: indexPath.section)
    }
    
    fileprivate func calculateOriginalIndexPath(forItemAt indexPath: IndexPath) -> IndexPath? {
        
        for (index, info) in insertedPresenceItems.enumerated() {
            if info.0 == indexPath {
                return nil // it is an advert
            }
            
            if info.0.row > indexPath.row {
                return indexPathGenerator(for: indexPath, previousPresenceItems: index, offsetType: .original)
            }
        }
        
        return indexPathGenerator(for: indexPath, previousPresenceItems: insertedPresenceItems.count, offsetType: .original)
    }
    
    fileprivate func calculateAdjustedIndexPath(forItemAtOriginalIndexPath indexPath: IndexPath) -> IndexPath {
        
        for (index, info) in insertedPresenceItems.enumerated() {
            
            if info.0.row >= indexPath.row {
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
                    if info.0.row >= indexPath.row {
                        amountToIncrement += 1
                        index += 1
                    }
                }
                
                newArray.append((IndexPath(row: info.0.row + (adjustmentType == .insertion ? amountToIncrement : -amountToIncrement), section: info.0.section), info.1))
            }
            return newArray
        }
        
        var amendmentsForInsertions: [PresenceInfo] = generateArray(.insertion, adjustedInsertions)
        var amendmentsForDeletions: [PresenceInfo] = generateArray(.deletion, adjustedDeletions)
        var updatedInsertedPresenceItems: [PresenceInfo] = []
        
        // compare arrays to remain in sync!
        for index in 0..<amendmentsForInsertions.count {
            guard
                let infoAfterInsertions = amendmentsForInsertions[safe: index],
                let infoAfterDeletions = amendmentsForDeletions[safe: index],
                let infoBeforeAmendments = insertedPresenceItems[safe: index] else {
                    fatalError()    // TODO shall we think of an alternative for production? If we are out of sync the UITableView will most likely throw an exception anyway
            }
            
            let differenceForInsertions = infoAfterInsertions.0.row - infoBeforeAmendments.0.row
            let differenceForDeletions = infoAfterDeletions.0.row - infoBeforeAmendments.0.row
            let newRow = infoBeforeAmendments.0.row + differenceForInsertions + differenceForDeletions
            updatedInsertedPresenceItems.append((IndexPath(row: newRow, section: infoBeforeAmendments.0.section), infoBeforeAmendments.1))
        }
        
        insertedPresenceItems = updatedInsertedPresenceItems
    }
}

// MARK:- Collection Node Delegate

extension Sacaza { // TODO finish this off as it is just a simple test at the moment
    
    fileprivate func cellSelectedAtIndexPath(_ indexPath: IndexPath) {
        guard let originalIndexPath = calculateOriginalIndexPath(forItemAt: indexPath) else {
            // tapped an advert
            return
        }
        
        // TODO inform delegate
    }
}
