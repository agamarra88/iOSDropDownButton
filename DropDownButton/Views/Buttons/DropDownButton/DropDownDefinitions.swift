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
