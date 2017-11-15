//
//  Sacaza.swift
//  Expression
//
//  Created by Matt Harding on 14/11/2017.
//

import Foundation

protocol SacazaDelegate {
    func sacazaDidFailToDownloadAdverts(_ sacaza: Sacaza)
}

struct Sacaza {
    
    var adverts: [Advert] = []
    var delegate: SacazaDelegate?
    
    func insertAdvertsIntoCollectionView() {
        
    }
    
    func start() {
        
        APIRequest.getAdverts() { result in
            switch result {
            case .success(let adverts):
                self.delegate?.sacazaDidFailToDownloadAdverts(self)
            case .error:
                self.delegate?.sacazaDidFailToDownloadAdverts(self)
            }
        }
    }
    
}
