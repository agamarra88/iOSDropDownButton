//
//  TapGestureRecognizer.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/27/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

class UITapClosureGestureRecognizer: UITapGestureRecognizer {
    
    // MARK: - Definition
    typealias closureTapGestureHandler = (UITapGestureRecognizer) -> Void
    
    // MARK: - Properties
    var tapGestureAction: closureTapGestureHandler?
    
    // MARK: - Constructor
    init() {
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(tapGestureRecognizerHandler(_:)))
    }
    
    init(action:@escaping closureTapGestureHandler) {
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(tapGestureRecognizerHandler(_:)))
        tapGestureAction = action
    }

    // MARK: - Action
    @objc private func tapGestureRecognizerHandler(_ recognizer:UITapGestureRecognizer) {
        tapGestureAction?(recognizer)
    }
    
}
