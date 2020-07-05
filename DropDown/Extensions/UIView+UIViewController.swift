//
//  UIView+UIViewController.swift
//  DropDown
//
//  Created by Arturo Gamarra on 6/30/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

extension UIView {
    
    var viewController: UIViewController? {
        var responder = next
        while !(responder is UIViewController) && responder != nil {
            responder = responder?.next
        }
        return responder as? UIViewController
    }
    
}
