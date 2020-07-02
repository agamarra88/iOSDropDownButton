//
//  DropDownViewCellable.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/26/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

// MARK: - Definitions
public typealias dropDownSelectedItemAction = (DropDownItemable, Int) -> Void

// MARK: - Constants
enum DropDownConstants {
    
    static let numberOfRowsToDisplay = 3
    static let imageViewWidth: CGFloat = 40
    
}

public enum DropDownDirection {
    
    case up
    case down
    
}

@objc public enum DropDownDismissOption: Int {
    
    case automatic  // No tap is needed to dismiss the drop down. As soon as the user interact with anything else than the drop down, the drop down is dismissed
    case onTap      // A tap inseide the drop down is needed to dismiss it
    case manual     // The drop down can only be dismissed manually (by code)
    
}

// MARK: - DropDownItemable
public protocol DropDownItemable: CustomStringConvertible {
    
    func isEqual(to other: DropDownItemable) -> Bool
    
}

extension String: DropDownItemable {
    
}

public extension DropDownItemable where Self: Equatable {
    
    func isEqual(to other: DropDownItemable) -> Bool {
        guard let otherItem = other as? Self else { return false }
        return self == otherItem
    }
}

// MARK: - DropDownViewCellable
public protocol DropDownViewCellable: class {

    func configureBy(item:DropDownItemable)
    
}
