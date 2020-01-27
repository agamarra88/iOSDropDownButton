//
//  ViewController.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/25/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dropDownButton: DropDownButton!
    @IBOutlet weak var dropDownButton2: DropDownButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let accounts = [Account(name: "Arturo Gamarra", number: "1234567890", amount: 12000),
                        Account(name: "Sebastian Mejia", number: "234567891", amount: 15000),
                        Account(name: "Andrea Cano", number: "987654321", amount: 3000),
                        Account(name: "Fabiola Chumpitaz", number: "7654321890", amount: 12000)]
        
        let nib = UINib(nibName: "AccountCell", bundle: Bundle.main)
        dropDownButton.registerReusable(nibCell: nib)
        dropDownButton.separatorStyle = .none
        dropDownButton.elements = accounts
        //dropDownButton.selectedElement = accounts[2]
        
        dropDownButton2.elements = ["Arturo", "Sebastian", "Gamarra", "Mejia", "Andrea", "Fabiola", "Cano", "Cumpitaz"]
    }


}

