//
//  DropDownView.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/27/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

@IBDesignable public class DropDownView: UIView, DropDownViewable {
    
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
    @IBInspectable public dynamic var borderColor: UIColor = .clear {
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
    @IBInspectable public dynamic var shadowRadius:CGFloat = 0 {
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
    
    // MARK: - Properties
    weak public var delegate:DropDownViewDelegate?
    public var selectedItemAction: dropDownSelectedItemAction?
    public var dropDownView: DropDownTableView
    public var arrowImageView: UIImageView?
    
    // MARK: - Constructors
    public override init(frame: CGRect) {
        dropDownView = DropDownTableView()
        
        super.init(frame: frame)
        setupView()
        setupArrowImageView()
    }
    
    public required init?(coder: NSCoder) {
        dropDownView = DropDownTableView()
        
        super.init(coder: coder)
        setupView()
        setupArrowImageView()
    }
}

// MARK: - Private
private extension DropDownView {
    
    func setupView() {
        let tapGesture = UITapClosureGestureRecognizer { _ in
            self.didTapped()
        }
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        
        setupDropDownViewable()
    }
}
