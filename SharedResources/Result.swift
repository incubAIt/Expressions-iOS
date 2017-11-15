//
//  Result.swift
//  Expression
//
//  Created by Matt Harding on 15/11/2017.
//

import Foundation

enum Result<T,E> {
    case success(T)
    case error(E)
}
