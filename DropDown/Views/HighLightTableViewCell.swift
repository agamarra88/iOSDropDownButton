//
//  HighLightTableViewCell.swift
//  DropDown
//
//  Created by Arturo Gamarra on 7/2/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

struct ElementHighLight: DropDownItemable {
    
    var element: DropDownItemable
    var range: Range<String.Index>?
    
    var description: String {
        return element.description
    }
    
    func isEqual(to other: DropDownItemable) -> Bool {
        return element.isEqual(to: other)
    }
}

final class HighLightTableViewCell: UITableViewCell, DropDownViewCellable {
    
    func configureBy(item: DropDownItemable) {        
        guard let font = textLabel?.font else { return }
            
        let text = item.description
        let attributedText = NSMutableAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: font.pointSize)])
        
        guard let element = item as? ElementHighLight
            , let range = element.range else {
            textLabel?.attributedText = attributedText
            return
        }

        let boldFont = UIFont.systemFont(ofSize: font.pointSize, weight: .bold)
        let nsRange = NSRange(range, in: text)
        attributedText.addAttributes([.font: boldFont], range: nsRange)
        textLabel?.attributedText = attributedText
    }
    
}
