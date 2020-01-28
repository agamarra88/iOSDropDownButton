//
//  DropDownViewCellable.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/26/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import Foundation

// MARK: - Definitions
typealias dropDownSelectedItemAction = (DropDownItemable, Int) -> Void

enum DropDownDirection {
    
    case up
    case down
    
}

@objc enum DropDownDismissOption:Int {
    
    case automatic  // No tap is needed to dismiss the drop down. As soon as the user interact with anything else than the drop down, the drop down is dismissed
    case onTap      // A tap inseide the drop down is needed to dismiss it
    case manual     // The drop down can only be dismissed manually (by code)
    
}

// MARK: - DropDownItemable
protocol DropDownItemable: CustomStringConvertible {
    
    func isEqual(to other: DropDownItemable) -> Bool
    
}

extension String:DropDownItemable {
    
}

extension DropDownItemable where Self: Equatable {
    
    func isEqual(to other: DropDownItemable) -> Bool {
        guard let otherItem = other as? Self else { return false }
        return self == otherItem
    }
}

// MARK: - DropDownViewCellable
protocol DropDownViewCellable:class {

    func configureBySetting(item:DropDownItemable)
    
}
