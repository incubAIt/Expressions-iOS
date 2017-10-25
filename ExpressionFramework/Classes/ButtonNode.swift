//
//  ButtonNode.swift
//  FootballFans
//
//  Created by Andrius Steponavicius on 06/03/2017.
//  Copyright © 2017 Andrius Steponavicius. All rights reserved.
//

import UIKit
import AsyncDisplayKit

extension ButtonNode {
    
    
    convenience init( _ touchUpAction:@escaping VoidHandler) {
        self.init()
        self.touchUpAction = touchUpAction
        self.addTarget(self, action: #selector(buttonTouchedUpInside), forControlEvents: .touchUpInside)
    }
    
    @objc func buttonTouchedUpInside() {
        self.touchUpAction?()
    }
}

class ButtonNode: ASButtonNode, Highlightable {
    
    override init() {
        super.init()
    }
    
    var touchUpAction:VoidHandler? {
        didSet{
            self.addTarget(self, action: #selector(buttonTouchedUpInside), forControlEvents: .touchUpInside)
        }
    }
    
    override var isEnabled: Bool {
        didSet{
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = self.isEnabled ? 1 : 0.1
            })

        }
    }
    
    override var isHighlighted: Bool {
        didSet{
            self.animate(isHighlighted)
        }
    }
    
    
    
    override var isSelected: Bool {
        didSet{
            self.animate(isSelected, true)
        }
    }
}
