//
//  SacazaAPI.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 24/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation

class SacazaAPI {
    
    let environmentUrl = "http://matts-mbp.ad1.tm-gnet.com:8000/" // TODO inject this into the class
    
    func getPresenceItems(completion: @escaping (Result<[PresenceInfo], Void>) -> Void) {
        
        // TODO find out what the end point is
        let request = APIRequest(endPoint: "1.json", environmentUrl: environmentUrl, httpMethod: "GET")
        request.fire() { jsonObject, error in
            
            guard
                let arrayOfPresenceDictionaries = jsonObject as? [[String: AnyObject]]
                else {
                    DispatchQueue.main.async {
                        completion(.error(()))
                    }
                    return
            }
            
            let presenceItems: [ExpressionRepresentable] = arrayOfPresenceDictionaries.flatMap{ PresenceItem(jsonDictionary: $0) }
            var indexToInsert = 0
            let presenceItemsWithIndexPaths: [PresenceInfo] = presenceItems.map({
                indexToInsert += 4  // TODO these indexes should be coming from the server
                return PresenceInfo(indexPath: IndexPath(row: indexToInsert, section: 0), expressionContainer: $0)
            })
            DispatchQueue.main.async {
                completion(.success(presenceItemsWithIndexPaths))
            }
        }
    }
}
