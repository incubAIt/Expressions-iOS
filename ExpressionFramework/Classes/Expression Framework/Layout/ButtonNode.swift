//
//  ButtonNode.swift
//  FootballFans
//
//  Created by Andrius Steponavicius on 06/03/2017.
//  Copyright © 2017 Andrius Steponavicius. All rights reserved.
//

import UIKit
import AsyncDisplayKit

typealias ActionButtonHandler = ((_ actionId: String) -> Void)

extension ButtonNode {
    
    convenience init( _ touchUpAction:@escaping ActionButtonHandler) {
        self.init()
        self.touchUpAction = touchUpAction
        self.addTarget(self, action: #selector(buttonTouchedUpInside), forControlEvents: .touchUpInside)
    }
    
    @objc func buttonTouchedUpInside() {
        self.touchUpAction?(actionId)
    }
}

extension ButtonNode {
    convenience init( _ dictionary:[String:AnyObject]) {
        self.init()
        if let attributedText = dictionary["attributedText"] as? [String:AnyObject] {
            self.setAttributedTitle(NSAttributedString(attributedText), for: [])
        }
        actionId = dictionary["actionId"] as? String ?? ""
        
        self.imageNode.contentMode = .scaleAspectFit
        if let stateDictionary = dictionary["states"] as? [String: AnyObject] {
            downloadImageAssets(fromStateDictionary: stateDictionary)
        }
    }
    
    private func downloadImageAssets(fromStateDictionary dictionary: [String: AnyObject]) {
        
        let states: [UIControlState] = [.normal, .highlighted, .disabled, .selected]
        states.forEach({
            guard
                let urlString = dictionary[$0.jsonPropertyKey] as? String,
                let url = URL(string: urlString) else {
                    return
            }
            setImageURL(url, for: $0)
        })
    }
}

private extension UIControlState {
    var jsonPropertyKey: String {
        switch self {
        case .normal: return "normal"
        case .highlighted: return "highlighted"
        case .disabled: return "disabled"
        case .selected: return "selected"
        default:
            return ""
        }
    }
}

class ButtonNode: ASButtonNode, Highlightable {
    
    private (set) var actionId: String = ""
    
    override init() {
        super.init()
    }
    
    var touchUpAction: ActionButtonHandler? {
        didSet{
            let selector = #selector(buttonTouchedUpInside)
            let controlEvent: ASControlNodeEvent = .touchUpInside
            removeTarget(self, action: selector, forControlEvents: controlEvent)
            addTarget(self, action: selector, forControlEvents: controlEvent)
        }
    }
    
    override var isEnabled: Bool {  // TODO cant we use the default states? i.e. .disabled state
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
    
    func setImageURL(_ url: URL, for controlState: UIControlState) {
        
        // TODO have a method to cancel a download.
        ImageDownloader.shared.download(from: url) { [weak self] result in
            
            switch result {
            case .success (let image):
                self?.setImage(image, for: controlState)
            case .error: break
            }
        }
        
    }
}
