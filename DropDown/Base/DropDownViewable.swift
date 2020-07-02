//
//  DropDownViewable.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/27/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

public protocol DropDownViewDelegate: class {
    
    func dropDown(_ sender:DropDownViewable, didSelectItem item:DropDownItemable, atIndex index:Int)
    
    func dropDown(_ sender:DropDownViewable, willShowWithDirection direction:DropDownDirection)
    func dropDown(_ sender:DropDownViewable, didShowWithDirection direction:DropDownDirection)
    func dropDown(_ sender:DropDownViewable, willDismissWithDirection direction:DropDownDirection)
    func dropDown(_ sender:DropDownViewable, didDismissWithDirection direction:DropDownDirection)
    
}

public extension DropDownViewDelegate {
    
    func dropDown(_ sender:DropDownViewable, willShowWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownViewable, didShowWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownViewable, willDismissWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownViewable, didDismissWithDirection direction:DropDownDirection) { }
    
}

public protocol DropDownViewable: class, UIGestureRecognizerDelegate {
    
    var cornerRadius: CGFloat { get set }
    var borderWidth: CGFloat { get set }
    var borderColor: UIColor { get set }
    var dropDownBorderWidth: CGFloat { get set }
    var dropDownBorderColor: UIColor { get set }
    var shadowColor: UIColor { get set }
    var shadowOpacity: CGFloat { get set }
    var shadowOffset: CGSize { get set }
    var shadowRadius: CGFloat { get set }
    var arrowImage: UIImage? { get set }
    var arrowImageContentMode: UIView.ContentMode { get set }
    var separatorStyle: UITableViewCell.SeparatorStyle { get set }
    var dropDownOffset: CGFloat { get set }
    var dropDownRowsToDisplay: Int { get set }
    
    var dismissOption: DropDownDismissOption { get set }
    var direction: DropDownDirection { get }
    var isShowing: Bool { get }
    var elements: [DropDownItemable] { get set }
    var selectedElement:DropDownItemable? { get set }
    
    var selectedItemAction: DropDownSelectedItemAction? { get set }
    var dropDownDelegate: DropDownViewDelegate? { get set }
    var dropDownView: DropDownTableView { get set }
    var arrowImageView: UIImageView? { get set }
    
    func showDropDown()
    func dismissDropDown()
}

// MARK: - Public - Properties Override
extension DropDownViewable {
    
    public var dropDownOffset: CGFloat {
        get {
            dropDownView.offset
        }
        set {
            dropDownView.offset = newValue
        }
    }
    
    public var dropDownRowsToDisplay: Int {
        get {
            dropDownView.rowToDisplay
        }
        set {
            dropDownView.rowToDisplay = newValue
        }
    }
    
    public var dismissOption: DropDownDismissOption {
        get {
            dropDownView.dismissOption
        }
        set {
            dropDownView.dismissOption = newValue
        }
    }
    
    public var direction: DropDownDirection {
        get {
            dropDownView.direction
        }
    }
    
    public var isShowing: Bool {
        get {
            dropDownView.isShowing
        }
    }
    
    public var elements: [DropDownItemable] {
        get {
            dropDownView.elements
        }
        set {
            dropDownView.elements = newValue
            dropDownView.reload()
        }
    }
    
    public var selectedElement: DropDownItemable? {
        get {
            dropDownView.selectedElement
        }
        set {
            dropDownView.select(item: newValue, animated: false)
        }
    }
}

// MARK: - Public - Setups
public extension DropDownViewable where Self: UIView {
    
    func setupDropDownViewable() {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        
        setupDropDownView()
    }
    
    func setupArrowImageView() {
        let imageViewWidth = DropDownConstants.imageViewWidth
        let isRightToLeft = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        
        let image = arrowImage ?? UIImage(named: "dropDownArrowDown")
        arrowImageView = UIImageView(image: image)
        arrowImageView?.contentMode = arrowImageContentMode
        arrowImageView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowImageView!)
        
        var horizontalConstraint:NSLayoutConstraint!
        if isRightToLeft {
            horizontalConstraint = arrowImageView?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        } else {
            horizontalConstraint = arrowImageView?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        }
        NSLayoutConstraint.activate([horizontalConstraint,
                                     arrowImageView!.widthAnchor.constraint(equalToConstant: imageViewWidth),
                                     arrowImageView!.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                                     arrowImageView!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)])
    }
    
    private func setupDropDownView() {
        dropDownView = DropDownTableView()
        dropDownView.cornerRadius = cornerRadius
        dropDownView.borderWidth = dropDownBorderWidth
        dropDownView.borderColor = dropDownBorderColor
        dropDownView.shadowColor = shadowColor
        dropDownView.shadowOpacity = shadowOpacity
        dropDownView.shadowOffset = shadowOffset
        dropDownView.shadowRadius = shadowRadius
        dropDownView.separatorStyle = separatorStyle
        
        if let _ = superview {
            dropDownView.attach(to: self)
        }
        
        dropDownView.selectedItemAction = { [unowned self] (item, index) in
            self.selectedElement = item
            self.selectedItemAction?(item, index)
            self.dropDownDelegate?.dropDown(self, didSelectItem: item, atIndex: index)
            
            if self.dismissOption != .manual {
                self.dismissDropDown()
            }
        }
    }
    
}

// MARK: - Public - Actions
public extension DropDownViewable where Self: UIView {
    
    func didTapped() {
        // Add constraints if needed
        dropDownView.attach(to: self)
        
        UIApplication.shared.windows.first?.endEditing(true)
        if !dropDownView.isShowing {
            showDropDown()
        } else {
            // If dissmis option is manual do not dismiss
            if dismissOption != .manual {
                dismissDropDown()
            }
        }
    }
    
    func registerReusable(nibCell nib:UINib, withRowHeight rowHeight:CGFloat = UITableView.automaticDimension, estimatedRowHeight:CGFloat = 45) {
        dropDownView.registerReusable(nibCell: nib, withRowHeight: rowHeight, estimatedRowHeight: estimatedRowHeight)
    }
    
    func registerReusable(cell cellClass:AnyClass, withRowHeight rowHeight:CGFloat = UITableView.automaticDimension, estimatedRowHeight:CGFloat = 45) {
        dropDownView.registerReusable(cell: cellClass, withRowHeight: rowHeight, estimatedRowHeight: estimatedRowHeight)
    }
    
    func reload() {
        dropDownView.reload()
    }
    
    func showDropDown() {
        // Manage corners
        layer.maskedCorners = dropDownView.direction == .down ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        dropDownDelegate?.dropDown(self, willShowWithDirection: self.dropDownView.direction)
        dropDownView.show(animations: { [unowned self] in
            // Rotate arrow view as aditional animation
            if self.arrowImageView != nil {
                self.arrowImageView!.transform = self.arrowImageView!.transform.rotated(by: CGFloat.pi)
            }
            
            }, completion: { [unowned self] _ in
                self.dropDownDelegate?.dropDown(self, didShowWithDirection: self.dropDownView.direction)
        })
    }
    
    func dismissDropDown() {
        dropDownDelegate?.dropDown(self, willDismissWithDirection: self.dropDownView.direction)
        dropDownView.dismiss(animations: { [unowned self] in
            // Rotate arrow view
            if self.arrowImageView != nil {
                self.arrowImageView!.transform = self.arrowImageView!.transform.rotated(by: CGFloat.pi)
            }
            
            // Manage corners
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            }, completion: { [unowned self] _ in
                self.dropDownDelegate?.dropDown(self, didDismissWithDirection: self.dropDownView.direction)
        })
    }
}

