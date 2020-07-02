//
//  ViewController.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/25/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit
import DropDown

class ViewController: UIViewController {
    
    @IBOutlet weak var dropDowntextField: DropDownTextField!
    @IBOutlet weak var dropDownButton: DropDownButton!
    @IBOutlet weak var dropDownButton2: DropDownButton!
    @IBOutlet weak var dropDownView: DropDownView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    var accounts:[Account] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accounts = [Account(name: "Arturo Gamarra", number: "1234567890", amount: 12000),
                    Account(name: "Sebastian Mejia", number: "234567891", amount: 15000),
                    Account(name: "Andrea Cano", number: "987654321", amount: 3000),
                    Account(name: "Fabiola Chumpitaz", number: "7654321890", amount: 12000)]
        
        let nib = UINib(nibName: "AccountCell", bundle: Bundle.main)        
        dropDownView.registerReusable(nibCell: nib, withRowHeight: 80)
        dropDownView.elements = accounts
        dropDownView.selectedItemAction = { [unowned self] (item, _) in
            guard let account = item as? Account else { return }
            self.accountLabel.text = account.name
            self.amountLabel.text = account.amount.description
        }
        
        dropDownButton.registerReusable(nibCell: nib, withRowHeight: 80)
        dropDownButton.elements = accounts
        dropDownButton.selectedElement = accounts[2]
        dropDownButton.dropDownDelegate = self
        
        dropDownButton2.elements = ["Arturo", "Sebastian", "Gamarra", "Mejia", "Andrea", "Fabiola", "Cano", "Cumpitaz"]
        dropDownButton2.dropDownRowsToDisplay = 3
//        dropDownButton2.dismissOption = .manual
        dropDownButton2.selectedItemAction = { (item, _) in
            print(item)
        }
        
        dropDowntextField.elements = ["Arturo", "Sebastian", "Gamarra", "Mejia", "Andrea", "Fabiola", "Cano", "Cumpitaz"]
        dropDowntextField.placeholder = "Select One"
        dropDowntextField.selectedItemAction = { item, _ in
            
        }
    }
}

extension ViewController: DropDownViewDelegate {
    
    func dropDown(_ sender: DropDownViewable, didSelectItem item: DropDownItemable, atIndex index: Int) {
        print(item)
    }
    
}
