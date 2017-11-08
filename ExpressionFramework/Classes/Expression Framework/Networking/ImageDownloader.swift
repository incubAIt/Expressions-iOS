//
//  ImageDownloader.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 08/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation
import AsyncDisplayKit

enum Result<T, E> {
    case success (T)
    case error (E)
}

class ImageDownloader {
    
    let imageRetriever: ASImageCacheProtocol & ASImageDownloaderProtocol
    
    static let shared: ImageDownloader = {
        let imageRetriever = ASPINRemoteImageDownloader.shared()    // Same as Networking Image Node to use the same cache
        return ImageDownloader(imageRetriever: imageRetriever)
    }()
    
    func download(from url: URL, completion:@escaping (Result<UIImage, Void>) -> Void) {
    
        // TODO check if we need to access the cache first
        imageRetriever.downloadImage(with: url, callbackQueue: DispatchQueue.main, downloadProgress: nil) { imageContainer, error, _ in
            guard let image = imageContainer?.asdk_image() else {
                completion(.error(()))
                return
            }
            completion(.success(image))
        }
    }
    
    init(imageRetriever: ASImageCacheProtocol & ASImageDownloaderProtocol) {
        self.imageRetriever = imageRetriever
    }
}
