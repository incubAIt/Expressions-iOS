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

class CollectionNodeSacazaTests: XCTestCase {
    
    var collectionNode: ASCollectionNode?
    var collectionNodeSacaza: CollectionNodeSacaza?
    var feedItems: [String] = []
    
    override func setUp() {
        super.setUp()
        
        let collectionNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
        self.collectionNode = collectionNode
        
        feedItems = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
        let downloadedPresenceItems =  [
            PresenceInfo(indexPath: IndexPath(row:3 , section: 1), expressionContainer: TestableAdvert("advertAtRow3")),
            PresenceInfo(indexPath: IndexPath(row:7 , section: 1), expressionContainer: TestableAdvert("advertAtRow7")),
            PresenceInfo(indexPath: IndexPath(row:11 , section: 1), expressionContainer: TestableAdvert("advertAtRow11")),
            PresenceInfo(indexPath: IndexPath(row:15 , section: 1), expressionContainer: TestableAdvert("advertAtRow15"))
        ]
        
        let sacaza = Sacaza(presenceItems: downloadedPresenceItems, numberOfOriginalItems: feedItems.count)
        
        collectionNodeSacaza = CollectionNodeSacaza(collectionNode: collectionNode, dataSource: self, sacaza: sacaza)
    }
    
    func test() {
        
        // TODO manipulate the adverts, test the rows, cells and selections etc
        
        
    }
    
}

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
