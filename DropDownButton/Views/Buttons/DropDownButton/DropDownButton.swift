//
//  DropDownButton.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/25/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

@IBDesignable class DropDownButton: UIButton, DropDownViewable {
    
    // MARK: - Properties - Inspectables & Configuration
    @IBInspectable dynamic var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            dropDownView.cornerRadius = cornerRadius
        }
    }
    @IBInspectable dynamic var borderWidth: CGFloat = 0 {
        willSet {
            dropDownBorderWidth = newValue
        }
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable dynamic var borderColor: UIColor = .clear {
        willSet {
            dropDownBorderColor = newValue
        }
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable dynamic var dropDownBorderWidth: CGFloat = 0 {
        didSet {
            dropDownView.borderWidth = dropDownBorderWidth
        }
    }
    @IBInspectable dynamic var dropDownBorderColor: UIColor = .clear {
        didSet {
            dropDownView.borderColor = dropDownBorderColor
        }
    }
    @IBInspectable dynamic var shadowColor: UIColor = .clear {
        didSet {
            dropDownView.shadowColor = shadowColor
        }
    }
    @IBInspectable dynamic var shadowOpacity: CGFloat = 0 {
        didSet {
            dropDownView.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable dynamic var shadowOffset: CGSize = .zero {
        didSet {
            dropDownView.shadowOffset = shadowOffset
        }
    }
    @IBInspectable dynamic var shadowRadius:CGFloat = 0 {
        didSet {
            dropDownView.shadowRadius = shadowRadius
        }
    }
    @IBInspectable dynamic var dropDownOffset:CGFloat = 0 {
        didSet {
            dropDownOffsetChanged()
        }
    }
    @objc dynamic var separatorStyle:UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            dropDownView.separatorStyle = separatorStyle
        }
    }
    @objc dynamic var dismissOption:DropDownDismissOption = .automatic
    
    // MARK: - Properties
    private var placeholder: String = ""
    var backgroundTapGesture: UITapClosureGestureRecognizer?
    var dropDownViewHeightConstraint: NSLayoutConstraint?
    var whenShowScrollToSelection:Bool = false
    var showDirection: DropDownDirection = .down {
        didSet {
            showDirectionChanged()
        }
    }
    var isShowing: Bool = false {
        didSet {
            isShowingChanged()
        }
    }
    
    weak var delegate:DropDownViewDelegate?
    var selectedItemAction: dropDownSelectedItemAction?
    
    var dropDownView: DropDownTableView
    var arrowImageView: UIImageView!
    var elements: [DropDownItemable] = [] {
        didSet {
            elementsChanged()
        }
    }
    var selectedElement:DropDownItemable? {
        didSet {
            if let element = selectedElement {
                setTitle(element.description, for: .normal)
            } else {
                setTitle(placeholder, for: .normal)
            }
            selectedElementchanged(fromOldValue: oldValue)
        }
    }
    
    // MARK: - Constructors
    override init(frame: CGRect) {
        dropDownView = DropDownTableView()
        
        super.init(frame: frame)
        setupButton()
        setupArrowImage()
    }
    
    required init?(coder: NSCoder) {
        dropDownView = DropDownTableView()
        
        super.init(coder: coder)
        setupButton()
        setupArrowImage()
    }
    
    // MARK: - Private
    private func setupButton() {
        setupDropDownViewable()
        
        placeholder = titleLabel?.text ?? ""
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    private func setupArrowImage() {
        let imageViewWidth = DropDownConstants.imageViewWidth
        let isRightToLeft = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        let rightInsents = !isRightToLeft ? imageViewWidth : 0
        let leftInsents = isRightToLeft ? imageViewWidth : 0
        titleEdgeInsets = UIEdgeInsets(top: 0, left: leftInsents, bottom: 0, right: rightInsents)
        
        setupArrowImageView()
    }
    
    // MARK: - Action
    @IBAction private func buttonTapped(_ sender:DropDownButton) {
        didTapped()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DropDownButton: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return isAnOutside(touch: touch)
    }
}
