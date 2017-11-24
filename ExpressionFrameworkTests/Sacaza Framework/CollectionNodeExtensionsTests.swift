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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
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



extension ASCollectionNode {
    
    private struct AssociatedKeys {
        static var sacaza: UInt8 = 0
    }
    
    var sacaza: CollectionNodeSacaza? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.sacaza) as? CollectionNodeSacaza
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.sacaza, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func startUsingSacaza() {
        // add as an associated object
        // or use a singleton to store a Sacaza object for each instance as a key
    }
    
}

// TODO need to download the adverts too




