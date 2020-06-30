//
//  TapGestureRecognizer.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/27/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

public class UITapClosureGestureRecognizer: UITapGestureRecognizer {
    
    // MARK: - Definition
    public typealias closureTapGestureHandler = (UITapGestureRecognizer) -> Void
    
    // MARK: - Properties
    public var tapGestureAction: closureTapGestureHandler?
    
    // MARK: - Constructor
    public init() {
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(tapGestureRecognizerHandler(_:)))
    }
    
    public init(action:@escaping closureTapGestureHandler) {
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(tapGestureRecognizerHandler(_:)))
        tapGestureAction = action
    }

    // MARK: - Action
    @objc private func tapGestureRecognizerHandler(_ recognizer:UITapGestureRecognizer) {
        tapGestureAction?(recognizer)
    }
    
}
