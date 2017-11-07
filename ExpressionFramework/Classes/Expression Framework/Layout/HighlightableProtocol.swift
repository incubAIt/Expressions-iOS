//
//  HighlightableProtocol.swift
//  hyperlocalNews
//
//  Created by Andrius Steponavicius on 05/07/2017.
//  Copyright © 2017 Andrius Steponavicius. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

public typealias VoidHandler = ()->Void

extension Highlightable where Self:ASDisplayNode {
    
    func animate(_ highlight:Bool, _ unhighlightWhenComplete:Bool = false) {
        UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.25, options: .beginFromCurrentState, animations: {[weak self] in
            if highlight {
                self?.transform = CATransform3DMakeScale(1.02, 1.02, 1.02)
            }else if !unhighlightWhenComplete {
                self?.transform = CATransform3DMakeScale(1, 1, 1)
            }
        }, completion:{[weak self] complete in
            if highlight && unhighlightWhenComplete {
                self?.animate(false)
            }
        })
    }
}

protocol Highlightable {
    var transform: CATransform3D {get set}
}
