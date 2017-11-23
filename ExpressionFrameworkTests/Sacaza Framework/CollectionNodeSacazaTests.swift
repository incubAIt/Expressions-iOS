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
    
    // MARK:- tests
    
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
