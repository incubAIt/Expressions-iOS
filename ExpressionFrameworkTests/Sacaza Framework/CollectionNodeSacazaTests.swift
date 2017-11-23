//
//  CollectionNodeSacazaTests.swift
//  ExpressionFrameworkTests
//
//  Created by Matt Harding on 21/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import XCTest
import AsyncDisplayKit
@testable import ExpressionFramework

class CollectionNodeSacazaTests: XCTestCase {
    
    // TODO run the same sweet of tests but with different data and indexes
    var collectionNode: ASCollectionNode?
    var collectionNodeSacaza: CollectionNodeSacaza?
    var feedItems: [String] = []
    var expectedIndexPathWhenCellIsSelected: IndexPath?
    
    override func setUp() {
        super.setUp()
        
        let collectionNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
        self.collectionNode = collectionNode
        
        feedItems = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
        let downloadedPresenceItems =  [
            PresenceInfo(indexPath: IndexPath(row:3 , section: 0), expressionContainer: TestableAdvert("advertAtRow3")),
            PresenceInfo(indexPath: IndexPath(row:7 , section: 0), expressionContainer: TestableAdvert("advertAtRow7")),
            PresenceInfo(indexPath: IndexPath(row:11 , section: 0), expressionContainer: TestableAdvert("advertAtRow11")),
            PresenceInfo(indexPath: IndexPath(row:15 , section: 0), expressionContainer: TestableAdvert("advertAtRow15"))
        ]
        
        let sacaza = Sacaza(presenceItems: downloadedPresenceItems, numberOfOriginalItems: feedItems.count)
        
        collectionNodeSacaza = CollectionNodeSacaza(collectionNode: collectionNode, dataSource: self, delegate: self, sacaza: sacaza)
    }
    
    
    // MARK:- Sacaza tests
    
    func testTheAdjustedIndexPaths() {
        let downloadedPresenceItems =  [
            PresenceInfo(indexPath: IndexPath(row:3 , section: 0), expressionContainer: TestableAdvert("advertAtRow3")),
            PresenceInfo(indexPath: IndexPath(row:7 , section: 0), expressionContainer: TestableAdvert("advertAtRow7")),
            PresenceInfo(indexPath: IndexPath(row:11 , section: 0), expressionContainer: TestableAdvert("advertAtRow11")),
            PresenceInfo(indexPath: IndexPath(row:15 , section: 0), expressionContainer: TestableAdvert("advertAtRow15"))
        ]
        
        let sacaza = Sacaza(presenceItems: downloadedPresenceItems, numberOfOriginalItems: feedItems.count)
        
        XCTAssertEqual(0, sacaza.calculateAdjustedIndexPath(forItemAtOriginalIndexPath: IndexPath(row: 0, section: 0)).row)
        XCTAssertEqual(4, sacaza.calculateAdjustedIndexPath(forItemAtOriginalIndexPath: IndexPath(row: 3, section: 0)).row)
        XCTAssertEqual(8, sacaza.calculateAdjustedIndexPath(forItemAtOriginalIndexPath: IndexPath(row: 6, section: 0)).row)
        XCTAssertEqual(12, sacaza.calculateAdjustedIndexPath(forItemAtOriginalIndexPath: IndexPath(row: 9, section: 0)).row)
    }
    
    // MARK:- Collection Node Tests
    
    func testTheNumberOfItems() {
        
        // given - the adverts, the feed, and that its merged
        
        // where - the datasource is not large enough to insert the last advert
        
        // then
        XCTAssertEqual(13, collectionNode?.numberOfItems(inSection: 0))
    }
    
    func testThatAllCellsAreTheCorrectType() {
        
        // given - the adverts, the feed, that its merged and we have 3 adverts
        
        // where
        
        // then
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 0, section: 0)) is TestableCellNode )
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 1, section: 0)) is TestableCellNode )
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 2, section: 0)) is TestableCellNode )
        
        XCTAssertFalse( collectionNode?.nodeForItem(at: IndexPath(row: 3, section: 0)) is TestableCellNode ) // Presence Item
        
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 4, section: 0)) is TestableCellNode )
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 5, section: 0)) is TestableCellNode )
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 6, section: 0)) is TestableCellNode )
        
        XCTAssertFalse( collectionNode?.nodeForItem(at: IndexPath(row: 7, section: 0)) is TestableCellNode ) // Presence Item
        
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 8, section: 0)) is TestableCellNode )
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 9, section: 0)) is TestableCellNode )
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 10, section: 0)) is TestableCellNode )
        
        XCTAssertFalse( collectionNode?.nodeForItem(at: IndexPath(row: 11, section: 0)) is TestableCellNode ) // Presence Item
        
        XCTAssertTrue( collectionNode?.nodeForItem(at: IndexPath(row: 12, section: 0)) is TestableCellNode )
    }
    
    func testTheSelection() {
        
        // given
        let originalIndexPaths = [IndexPath(row: 3, section: 0), IndexPath(row: 6, section: 0), IndexPath(row: 9, section: 0)]
        let adjustedIndexPaths = [IndexPath(row: 4, section: 0), IndexPath(row: 8, section: 0), IndexPath(row: 12, section: 0)]
        
        // when
        for index in 0..<originalIndexPaths.count {
            expectedIndexPathWhenCellIsSelected = originalIndexPaths[index]
            collectionNodeSacaza!.collectionNode(collectionNode!, didSelectItemAt: adjustedIndexPaths[index])
        }
        
        // then - the delegate methods handle the response
    }
    
    func testInsertions() {
        
        // given
        let newFeedItems = [("oneA", 0),("twoA", 1),("threeA", 2),("fourA", 3),("fiveA", 4),("sixA", 5),("sevenA", 6),("eightA", 7),("nineA", 8),("tenA", 9),("elevenA", 10)]
        
        // when
        feedItems.insertItems(newFeedItems, deleteItemsAtIndexes: [])
        let indexPaths = newFeedItems.map({ IndexPath(row: $0.1, section: 0)})
        collectionNodeSacaza!.insertItems(insertions: indexPaths, deletions: [])
        let expectedFeedItems: [Any] =  ["oneA", "one", "twoA", "two", "threeA", "three", TestableAdvert("advertAtRow3"), "fourA", "four", "fiveA", "five", "sixA", "six",  TestableAdvert("advertAtRow7"), "sevenA", "seven", "eightA", "eight", "nineA", "nine", TestableAdvert("advertAtRow11"), "tenA", "ten", "elevenA"]
        
        // then
        for (index, finalFeedItem) in expectedFeedItems.enumerated() {
            switch finalFeedItem {
            case let item as String:
                guard let cell = collectionNode!.nodeForItem(at: IndexPath(row: index, section: 0)) as? TestableCellNode else {
                    XCTFail("Expected TestableCellNode type")
                    return
                }
                XCTAssertEqual(cell.text, item)
            case _ as TestableAdvert:
                if let _ = collectionNode!.nodeForItem(at: IndexPath(row: index, section: 0)) as? TestableCellNode {
                    XCTFail("Expected ASCellNode for Advert")
                }
            default:
                XCTFail("Unexpected scenario")
            }
        }
    }
    
    func testDeletions() {
        
    }
    
    func testInsertionsAndDeletions() {
        
    }
}

// MARK:- Support for Tests

extension CollectionNodeSacazaTests: SacazaCollectionNodeDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let text = feedItems[indexPath.row]
        let cell = TestableCellNode(text: text)
        return cell
    }
}

extension CollectionNodeSacazaTests: SacazaCollectionNodeDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        guard let expectedIndexPath = expectedIndexPathWhenCellIsSelected else {
            XCTFail("No indexpath was set before executing this test")
            return
        }
        
        XCTAssertEqual(expectedIndexPath, indexPath)
    }
}

private struct TestableAdvert: ExpressionRepresentable {
    let text: String
    var expression: Expression? = nil
    
    init(_ text: String) {
        self.text = text
    }
}

private class TestableCellNode: ASCellNode {
    let text: String
    
    init(text: String) {
        self.text = text
        super.init()
    }
}
