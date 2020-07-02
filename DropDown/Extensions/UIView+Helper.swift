//
//  UIView+Helper.swift
//  DropDown
//
//  Created by Arturo Gamarra on 7/1/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

extension UIView {
    
    func superView<T: UIView>(of type: T.Type) -> T? {
        var parent = self.superview
        while !(parent is T) && parent != nil {
            parent = parent?.superview
        }
        return parent as? T
    }
}
