//
//  DropDownButton.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/25/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

protocol DropDownButtonDelegate:class {
    
    func dropDownButton(_ sender:DropDownButton, didSelectItem item:DropDownItemable, atIndex index:Int)
    
    func dropDownButtonWillShowDropDown(_ sender:DropDownButton)
    func dropDownButtonDidShowDropDown(_ sender:DropDownButton)
    func dropDownButtonWillHideDropDown(_ sender:DropDownButton)
    func dropDownButtonDidHideDropDown(_ sender:DropDownButton)
    
}

extension DropDownButtonDelegate {
    
    func dropDownButtonWillShowDropDown(_ sender:DropDownButton) {}
    func dropDownButtonDidShowDropDown(_ sender:DropDownButton) {}
    func dropDownButtonWillHideDropDown(_ sender:DropDownButton) {}
    func dropDownButtonDidHideDropDown(_ sender:DropDownButton) {}
    
}

@IBDesignable class DropDownButton: UIButton {
    
    // MARK: - Constants
    private let numberOfRowsToShow = 3
    
    // MARK: - Properties - Inspectables & Configuration
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            dropDownView.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var dropDownBorderWidth: CGFloat = 1 {
        didSet {
            dropDownView.layer.borderWidth = dropDownBorderWidth
        }
    }
    @IBInspectable var dropDownBorderColor: UIColor = .lightGray {
        didSet {
            dropDownView.layer.borderColor = dropDownBorderColor.cgColor
        }
    }
    var separatorStyle:UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            dropDownView.separatorStyle = separatorStyle
        }
    }
    
    // MARK: - Properties
    private var dropDownViewHeightConstraint: NSLayoutConstraint?
    private var placeholder: String = ""
    private var onOpenScrollToSelection:Bool = false
    private(set)var isOpen: Bool = false {
        didSet {
            let image = isOpen ? UIImage(named: "dropDownArrowUp") : UIImage(named: "dropDownArrowDown")
            arrowImageView.image = image
        }
    }
    
    weak var delegate:DropDownButtonDelegate?
    var selectedItemAction: dropDownSelectedItemAction?
    
    var dropDownView: DropDownTableView!
    var arrowImageView: UIImageView!
    var elements: [DropDownItemable] = [] {
        didSet {
            dropDownView.elements = elements
            dropDownView.tableView.reloadData()
        }
    }
    var selectedElement:DropDownItemable? {
        didSet {
            if let element = selectedElement {
                setTitle(element.description, for: .normal)
            } else {
                setTitle(placeholder, for: .normal)
            }
            dropDownView.select(item: selectedElement, animated: false)
            onOpenScrollToSelection = oldValue == nil
        }
    }
    
    // MARK: - Calculated Properties
    private var dropDownViewHeight:CGFloat {
        let factor = elements.count < numberOfRowsToShow ? elements.count : numberOfRowsToShow
        let height = dropDownView.tableView.rowHeight != UITableView.automaticDimension ? dropDownView.tableView.rowHeight : dropDownView.tableView.estimatedRowHeight
        return CGFloat(factor) * height // TODO: Improve calculation
    }
    
    // MARK: - Constructors
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        setupArrowImage()
        setupDropDownView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        setupArrowImage()
        setupDropDownView()
    }
    
    // MARK: - Private
    private func setupButton() {
        placeholder = titleLabel?.text ?? ""
        
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    private func setupArrowImage() {
        let imageViewWidth:CGFloat = 40
        let isRightToLeft = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        let rightInsents = !isRightToLeft ? imageViewWidth : 0
        let leftInsents = isRightToLeft ? imageViewWidth : 0
        titleEdgeInsets = UIEdgeInsets(top: 0, left: leftInsents, bottom: 0, right: rightInsents)
        
        let image = UIImage(named: "dropDownArrowDown")
        arrowImageView = UIImageView(image: image)
        arrowImageView.contentMode = .center
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowImageView)
        
        var horizontalConstraint:NSLayoutConstraint!
        if isRightToLeft {
            horizontalConstraint = arrowImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        } else {
            horizontalConstraint = arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        }
        NSLayoutConstraint.activate([horizontalConstraint,
                                     arrowImageView.widthAnchor.constraint(equalToConstant: imageViewWidth),
                                     arrowImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                                     arrowImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)])
    }
    
    private func setupDropDownView() {
        dropDownView = DropDownTableView()
        dropDownView.clipsToBounds = true
        dropDownView.layer.cornerRadius = cornerRadius
        dropDownView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        dropDownView.layer.borderWidth = dropDownBorderWidth
        dropDownView.layer.borderColor = dropDownBorderColor.cgColor
        dropDownView.separatorStyle = separatorStyle
        
        if let currentSuperView = superview {
            constraintDropDownView(toSuperView: currentSuperView)
        }
        
        dropDownView.elements = elements
        dropDownView.selectedItemAction = { [unowned self] (item, index) in
            self.selectedElement = item
            self.selectedItemAction?(item, index)
            self.delegate?.dropDownButton(self, didSelectItem: item, atIndex: index)
            self.closeDropDown()
        }
    }
    
    private func constraintDropDownView(toSuperView superView:UIView) {
        dropDownView.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(dropDownView)
        
        dropDownViewHeightConstraint = dropDownView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([dropDownViewHeightConstraint!,
                                     dropDownView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     dropDownView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     dropDownView.topAnchor.constraint(equalTo: bottomAnchor, constant: 0)])
    }
    
    // MARK: - Action
    @IBAction private func buttonTapped(_ sender:DropDownButton) {
        // Add constraints if needed
        if dropDownViewHeightConstraint == nil,
            let currentSuperView = superview {
            constraintDropDownView(toSuperView: currentSuperView)
            
            // Forcing the layout because then an animation will come. With this the view will be located in the right place for the animation
            dropDownView.layoutIfNeeded()
        }
        
        !isOpen ? openDropDown() : closeDropDown()
    }
    
}

// MARK: - Public
extension DropDownButton {
    
    func registerReusable(nibCell nib:UINib, withRowHeight rowHeight:CGFloat = UITableView.automaticDimension, estimatedRowHeight:CGFloat = 45) {
        dropDownView.registerReusable(nibCell: nib, withRowHeight: rowHeight, estimatedRowHeight: estimatedRowHeight)
    }
    
    func registerReusable(cell cellClass:AnyClass, withRowHeight rowHeight:CGFloat = UITableView.automaticDimension, estimatedRowHeight:CGFloat = 45) {
        dropDownView.registerReusable(cell: cellClass, withRowHeight: rowHeight, estimatedRowHeight: estimatedRowHeight)
    }
    
    func openDropDown() {
        isOpen = true
        
        // Scroll to Selected Item
        if onOpenScrollToSelection {
            dropDownView.scrollToSelectedIndex()
        }
        
        // Manage corners
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Animate and show DropDownView (TableView)
        dropDownViewHeightConstraint?.constant = dropDownViewHeight
        delegate?.dropDownButtonWillShowDropDown(self)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            self.dropDownView.layoutIfNeeded()
            self.dropDownView.center.y += self.dropDownView.frame.height / 2
            
        }, completion: { [unowned self] _ in
            self.delegate?.dropDownButtonDidShowDropDown(self)
        })
    }
    
    func closeDropDown() {
        isOpen = false
        onOpenScrollToSelection = false
        
        // Manage corners
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        // Animate and hide DropDownView (TableView)
        dropDownViewHeightConstraint?.constant = 0
        delegate?.dropDownButtonWillHideDropDown(self)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            self.dropDownView.center.y -= self.dropDownView.frame.height / 2
            self.dropDownView.layoutIfNeeded()
            
        }, completion: { [unowned self] _ in
            self.delegate?.dropDownButtonDidHideDropDown(self)
        })
    }
    
}
