//
//  Sacaza.swift
//  Expression
//
//  Created by Matt Harding on 14/11/2017.
//

import Foundation

public protocol SacazaDelegate {
    func sacazaDidFailToDownloadAdverts()
    func sacazaDidDownloadAdverts(_ adverts: [Advert])
}

public struct Sacaza {
    
    var adverts: [Advert] = []
    public var delegate: SacazaDelegate?
    
    public init() {
        
    }
    
    public func start() {
        
        APIRequest.getAdverts() { result in
            switch result {
            case .success(let adverts):
                self.delegate?.sacazaDidDownloadAdverts(adverts)
            case .error:
                self.delegate?.sacazaDidFailToDownloadAdverts()
            }
        }
    }
    
}
