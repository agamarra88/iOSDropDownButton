//
//  AppereanceManager.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/28/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

struct AppearanceManager {
    
    static func setupAppAppearance() {
        
        let dropDownButton = DropDownButton.appearance()
        dropDownButton.cornerRadius = 10
        dropDownButton.borderWidth = 1
        dropDownButton.borderColor = .lightGray
        dropDownButton.separatorStyle = .none
        
    }

}
