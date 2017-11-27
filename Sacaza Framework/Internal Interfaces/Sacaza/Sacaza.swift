//
//  Sacaza.swift
//  Expression
//
//  Created by Matt Harding on 14/11/2017.
//

import Foundation

// MARK:- Support for Tests

extension Sacaza {
    
    convenience init(sacazaAPI: SacazaAPI, presenceItems: [PresenceInfo], numberOfOriginalItems: Int) {
        self.init(sacazaAPI: sacazaAPI)
        
        self.downloadedPresenceItems = presenceItems
        self.reloadData(withNumberOfOriginalItems: numberOfOriginalItems)
    }
}

// MARK:- Class Declaration

public final class Sacaza {
    
    let sacazaAPI: SacazaAPI
    private var downloadedPresenceItems: [PresenceInfo] = [] // contains the adjusted index paths
    private var insertedPresenceItems: [PresenceInfo] = []   // contains the adjusted index paths
    private var numberOfOriginalItems: Int = 0
    
    private var isRefreshing = false
    
    init(sacazaAPI: SacazaAPI) {
        self.sacazaAPI = sacazaAPI
    }
    
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
        sacazaAPI.getPresenceItems() { result in
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
    
    func presenceItem(at indexPath: IndexPath) -> ExpressionRepresentable? {
        
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
    
    func calculateOriginalIndexPath(forItemAt indexPath: IndexPath) -> IndexPath? {
        
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
