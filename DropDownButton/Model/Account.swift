//
//  Account.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/26/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import Foundation

class Account: DropDownItemable {
    
    var name:String = ""
    var number:String = ""
    var amount:Double = 0
    
    var description: String {
        return name
    }
    
    init() {
        
    }
    
    init(name:String, number:String, amount:Double) {
        self.name = name
        self.number = number
        self.amount = amount
    }
    
    func isEqual(to other: DropDownItemable) -> Bool {
        guard let account = other as? Account else { return false}
        return number == account.number
    }
}
