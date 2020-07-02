//
//  DropDownButton.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/25/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

public class UIClosureButton: UIButton {
    
    // MARK: - Definition
    public typealias closureTouchUpInsideHandler = (UIButton) -> Void
    
    // MARK: - Properties
    public var touchUpInsideAction: closureTouchUpInsideHandler?
    
    // MARK: - Constructors
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    // MARK: - Private
    private func setupButton() {
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @IBAction private func buttonTapped(_ sender:UIButton) {
        touchUpInsideAction?(sender)
    }
    
}

@IBDesignable public class DropDownButton: UIClosureButton, DropDownViewable {
    
    // MARK: - Properties - Inspectables & Configuration
    @IBInspectable public dynamic var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            dropDownView.cornerRadius = cornerRadius
        }
    }
    @IBInspectable public dynamic var borderWidth: CGFloat = 0 {
        willSet {
            dropDownBorderWidth = newValue
        }
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable public  dynamic var borderColor: UIColor = .clear {
        willSet {
            dropDownBorderColor = newValue
        }
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable public dynamic var dropDownBorderWidth: CGFloat = 0 {
        didSet {
            dropDownView.borderWidth = dropDownBorderWidth
        }
    }
    @IBInspectable public dynamic var dropDownBorderColor: UIColor = .clear {
        didSet {
            dropDownView.borderColor = dropDownBorderColor
        }
    }
    @IBInspectable public dynamic var shadowColor: UIColor = .clear {
        didSet {
            dropDownView.shadowColor = shadowColor
        }
    }
    @IBInspectable public dynamic var shadowOpacity: CGFloat = 0 {
        didSet {
            dropDownView.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable public dynamic var shadowOffset: CGSize = .zero {
        didSet {
            dropDownView.shadowOffset = shadowOffset
        }
    }
    @IBInspectable public dynamic var shadowRadius: CGFloat = 0 {
        didSet {
            dropDownView.shadowRadius = shadowRadius
        }
    }
    @IBInspectable public dynamic var arrowImage: UIImage? {
        didSet {
            arrowImageView?.image = arrowImage
        }
    }
    @objc dynamic public var arrowImageContentMode: UIView.ContentMode = .center {
        didSet {
            arrowImageView?.contentMode = arrowImageContentMode
        }
    }
    @objc dynamic public var separatorStyle: UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            dropDownView.separatorStyle = separatorStyle
        }
    }
    @IBInspectable public dynamic var dropDownOffset: CGFloat {
        get {
            dropDownView.offset
        }
        set {
            dropDownView.offset = newValue
        }
    }
    @IBInspectable public dynamic var dropDownRowsToDisplay: Int {
        get {
            dropDownView.rowToDisplay
        }
        set {
            dropDownView.rowToDisplay = newValue
        }
    }
    
    // MARK: - Properties
    private var placeholder: String = ""
    
    public weak var delegate:DropDownViewDelegate?
    public var selectedItemAction: dropDownSelectedItemAction?
    public var dropDownView: DropDownTableView
    public var arrowImageView: UIImageView?
    
    public var selectedElement: DropDownItemable? {
        get {
            dropDownView.selectedElement
        }
        set {
            dropDownView.select(item: newValue, animated: false)
            if let element = selectedElement {
                setTitle(element.description, for: .normal)
            } else {
                setTitle(placeholder, for: .normal)
            }
        }
    }
    
    // MARK: - Constructors
    public override init(frame: CGRect) {
        dropDownView = DropDownTableView()
        
        super.init(frame: frame)
        setupButton()
        setupArrowImage()
    }
    
    public required init?(coder: NSCoder) {
        dropDownView = DropDownTableView()
        
        super.init(coder: coder)
        setupButton()
        setupArrowImage()
    }
    
    // MARK: - Private
    private func setupButton() {
        setupDropDownViewable()
        
        placeholder = titleLabel?.text ?? ""
        touchUpInsideAction = { [unowned self] sender in
            self.didTapped()
        }
    }
    
    private func setupArrowImage() {
        let imageViewWidth = DropDownConstants.imageViewWidth
        let isRightToLeft = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        let rightInsents = !isRightToLeft ? imageViewWidth : 0
        let leftInsents = isRightToLeft ? imageViewWidth : 0
        titleEdgeInsets = UIEdgeInsets(top: 0, left: leftInsents, bottom: 0, right: rightInsents)
        
        setupArrowImageView()
    }
}
