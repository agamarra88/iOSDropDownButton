//
//  AutoCompleteTextViewController.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 7/5/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit
import DropDown

class AutoCompleteTextViewController: UIViewController {
    
    @IBOutlet weak var dropDowntextField: DropDownTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        dropDowntextField.dropDownPreferredHeight = 300
        dropDowntextField.placeholder = "Select One"
        dropDowntextField.paging.pullToRefreshEnabled = true
        dropDowntextField.paging.infiniteScrollEnabled = true
        dropDowntextField.selectedItemAction = { item, _ in
            
        }
        dropDowntextField.loadPageAction = { [unowned self] textField, text, page in
            self.filterMovies(by: text, inPage: page)
        }
        dropDowntextField.filterAction = { [unowned self] text, page in
            if text.isEmpty {
                self.dropDowntextField.elements.removeAll()
            } else {
                self.filterMovies(by: text, inPage: page)
            }
        }
    }
    
    func filterMovies(by text: String, inPage page: Int) {
        let service = MovieService()
        service.search(by: text, in: page) { [unowned self] response in
            switch response {
            case .failure(let error):
                print(error)
            case .success(let searchMovieDTO):
                if page == 1 {
                    self.dropDowntextField.elements = searchMovieDTO.results
                } else {
                    self.dropDowntextField.elements.append(contentsOf: searchMovieDTO.results)
                }
                self.dropDowntextField.stopLoading()
            }
        }
    }
}
