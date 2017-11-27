//
//  APIRequest.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 27/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation

class APIRequest: NSObject {
    
    var url:URL?
    var endPoint:String = ""
    var httpMethod:String = "GET"
    var httpBody:Any?
    var sessionConfiguration:URLSessionConfiguration {
        return URLSessionConfiguration.default
    }
    
    init(endPoint:String, environmentUrl:String, httpMethod:String = "GET") {
        
        self.endPoint = endPoint
        self.url = URL(string: endPoint, relativeTo: URL(string: environmentUrl))
        self.httpMethod = httpMethod
    }
    
    var request:URLRequest? {
        
        guard let url = self.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        if let httpBody = self.httpBody {
            request.setValue("json", forHTTPHeaderField: "Data-Type")
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject:httpBody , options: .prettyPrinted)
            } catch {
                return nil
            }
        }
        return request
    }
    
    func fire(completion:@escaping (_ response:AnyObject?, _ error:Error?) -> Void) {
        
        guard let request = self.request else {
            let error = NSError( // TODO if we use this class in production we should use proper Error codes etc
                domain: "APIRequest",
                code: -1
            )
            completion(nil, error)
            return
        }
        
        URLSession(configuration: sessionConfiguration).dataTask(with: request) { data, response, error in
            
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            
            if jsonObject == nil {
                debugPrint(String(data: data, encoding: .utf8) as Any)
            }
            DispatchQueue.main.async {
                completion(jsonObject as AnyObject, error)
            }
            
            }.resume()
    }
    
}
