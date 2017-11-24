//
//  SacazaTests.swift
//  ExpressionFrameworkTests
//
//  Created by Matt Harding on 24/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import XCTest

class SacazaTests: XCTestCase {
    
    func testTheAdjustedIndexPaths() {
        
        // given
        let feedItems = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
        
        // when
        let downloadedPresenceItems =  [
            PresenceInfo(indexPath: IndexPath(row:3 , section: 0), expressionContainer: TestableAdvert("advertAtRow3")),
            PresenceInfo(indexPath: IndexPath(row:7 , section: 0), expressionContainer: TestableAdvert("advertAtRow7")),
            PresenceInfo(indexPath: IndexPath(row:11 , section: 0), expressionContainer: TestableAdvert("advertAtRow11")),
            PresenceInfo(indexPath: IndexPath(row:15 , section: 0), expressionContainer: TestableAdvert("advertAtRow15"))
        ]
        let sacaza = Sacaza(presenceItems: downloadedPresenceItems, numberOfOriginalItems: feedItems.count)
        
        // then
        XCTAssertEqual(0, sacaza.calculateAdjustedIndexPath(forItemAtOriginalIndexPath: IndexPath(row: 0, section: 0)).row)
        XCTAssertEqual(4, sacaza.calculateAdjustedIndexPath(forItemAtOriginalIndexPath: IndexPath(row: 3, section: 0)).row)
        XCTAssertEqual(8, sacaza.calculateAdjustedIndexPath(forItemAtOriginalIndexPath: IndexPath(row: 6, section: 0)).row)
        XCTAssertEqual(12, sacaza.calculateAdjustedIndexPath(forItemAtOriginalIndexPath: IndexPath(row: 9, section: 0)).row)
    }
}
