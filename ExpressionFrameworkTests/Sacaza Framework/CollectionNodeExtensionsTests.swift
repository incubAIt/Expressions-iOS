//
//  CollectionNodeExtensionsTests.swift
//  ExpressionFrameworkTests
//
//  Created by Matt Harding on 24/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import XCTest
import AsyncDisplayKit
@testable import ExpressionFramework

class CollectionNodeExtensionsTests: XCTestCase {
    
    func testAssociatedObjectsAreDifferentInstances() {
        
        let collectionNode1 = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
        let sacaza1 = collectionNode1.sacaza
        
        let collectionNode2 = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
        let sacaza2 = collectionNode2.sacaza
        
        if sacaza1 === sacaza2 {
            XCTFail("Both Sacaza references point to the same instance")
        }
    }
}
