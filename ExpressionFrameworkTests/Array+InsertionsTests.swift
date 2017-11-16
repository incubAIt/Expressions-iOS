//
//  Array+InsertionsTests.swift
//  ExpressionFrameworkTests
//
//  Created by Matt Harding on 16/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import XCTest
@testable import ExpressionFramework

class Array_InsertionsTests: XCTestCase {
    
    func testPrefixAndSuffix() {
        
        var array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let additions = [("-2", 0), ("-1", 0)]
        let deletions = [8, 9]
        array.insertItems(additions, deleteItemsAtIndexes: deletions)
        
        XCTAssertTrue(array == ["-2", "-1", "0", "1", "2", "3", "4", "5", "6", "7"])
    }
    
    func testDeletingEveryOther() {
        
        var array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let additions:[(String, Int)] = []
        let deletions = [1,3,5,7,9]
        array.insertItems(additions, deleteItemsAtIndexes: deletions)
        XCTAssertTrue(array == ["0", "2", "4", "6", "8"])
    }
    
    func testDeletingEveryValue() {
        
        var array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let additions:[(String, Int)] = []
        let deletions = [0,1,2,3,4,5,6,7,8,9]
        array.insertItems(additions, deleteItemsAtIndexes: deletions)
        XCTAssertTrue(array == [])
    }
    
    func testDeletingEveryValueAndAddingToZeroIndex() {
        
        var array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let additions:[(String, Int)] = [("0A", 0),("1A", 0),("2A", 0),("3A", 0),("4A", 0),("5A", 0),("6A", 0),("7A", 0),("8A", 0),("9A", 0)]
        let deletions = [0,1,2,3,4,5,6,7,8,9]
        array.insertItems(additions, deleteItemsAtIndexes: deletions)
        XCTAssertTrue(array == ["0A", "1A", "2A", "3A", "4A","5A", "6A", "7A","8A","9A"])
    }
    
    func testDeletingEveryValueAndAddingToSpecificIndexes() {
        
        var array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let additions:[(String, Int)] = [("0A", 0),("1A", 1),("2A", 2),("3A", 3),("4A", 4),("5A", 5),("6A", 6),("7A", 7),("8A", 8),("9A", 9)]
        let deletions = [0,1,2,3,4,5,6,7,8,9]
        array.insertItems(additions, deleteItemsAtIndexes: deletions)
        XCTAssertTrue(array == ["0A", "1A", "2A", "3A", "4A","5A", "6A", "7A","8A","9A"])
    }

    func testAddingOnly() {
        
        var array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let additions:[(String, Int)] = [("0A", 0),("1A", 1),("8A", 8),("9A", 9)]
        let deletions: [Int] = []
        array.insertItems(additions, deleteItemsAtIndexes: deletions)
        XCTAssertTrue(array == ["0A" ,"0", "1A","1", "2", "3", "4", "5", "6", "7", "8A", "8", "9A", "9"])
    }
    
}
