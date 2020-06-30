//
//  AccountCell.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/26/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit
import DropDown

class AccountCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
}

extension AccountCell: DropDownViewCellable {
    
    func configureBySetting(item: DropDownItemable) {
        guard let account = item as? Account else { return }
        
        accountLabel.text = account.number
        ownerLabel.text = account.name
        amountLabel.text = account.amount.description
    }
    
}
