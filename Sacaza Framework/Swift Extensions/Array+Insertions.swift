//
//  Array+Insertions.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 16/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation

// TODO we may not need this extension any more and it probably could be deleted
public extension Array {
    
    mutating func insertItems(_ insertedItems: [(Element, Int)], deleteItemsAtIndexes deletedIndexes: [Int]) {
        var amountToIncrementWIthinAdditions = 0
        insertedItems.forEach({ tuple in
            let index = amountToIncrementWIthinAdditions + tuple.1
            self.insert(tuple.0, at: index)
            amountToIncrementWIthinAdditions += 1   // TODO doesnt work!
        })
        
        var startingIndexWithinAdditions = 0
        var amountToIncrement = 1
        
        deletedIndexes.forEach({
            var index = $0
            
            let maximum = Swift.max(0,(insertedItems.count - 1))
            let minimum = startingIndexWithinAdditions
            if minimum <= maximum && insertedItems.count > 0 {
                
                for insertedIndex in minimum ... maximum {
                    let indexOfInsertedItem = insertedItems[insertedIndex].1
                    if indexOfInsertedItem <= index {
                        amountToIncrement += 1
                        startingIndexWithinAdditions = insertedIndex + 1
                        
                    } else {
                        
                        startingIndexWithinAdditions = insertedIndex
                        break
                    }
                }
            }
            amountToIncrement -= 1
            index += amountToIncrement

            self.remove(at: index)
        })
    }
    
}
