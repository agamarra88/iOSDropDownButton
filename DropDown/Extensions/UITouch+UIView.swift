//
//  UITouch+UIView.swift
//  DropDown
//
//  Created by Arturo Gamarra on 6/29/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

extension UITouch {
    
    public func isInside(view: UIView) -> Bool {
        let location = self.location(in: view)
        let inXAxis = view.bounds.origin.x <= location.x && location.x <= view.bounds.width
        let inYAxis = view.bounds.origin.y <= location.y && location.y <= view.bounds.height
        return inXAxis && inYAxis
    }
    
}
