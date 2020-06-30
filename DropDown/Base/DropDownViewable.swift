//
//  DropDownViewable.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/27/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

public protocol DropDownViewDelegate:class {
    
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
    var dropDownOffset: CGFloat { get set }
    var arrowImage: UIImage? { get set }
    var arrowImageContentMode: UIView.ContentMode { get set }
    var separatorStyle: UITableViewCell.SeparatorStyle { get set }
    var dismissOption:DropDownDismissOption { get set }
    
    var showDirection: DropDownDirection { get set }
    var whenShowScrollToSelection: Bool { get set }
    var isShowing: Bool { get set }
    
    var delegate:DropDownViewDelegate? { get set }
    var selectedItemAction: dropDownSelectedItemAction? { get set }
    
    var arrowImageView: UIImageView? { get set }
    var dropDownView: DropDownTableView { get set }
    var elements: [DropDownItemable] { get set }
    var selectedElement:DropDownItemable? { get set }
    
    func showDropDown()
    func dismissDropDown()
}


// MARK: - Calculated Properties
extension DropDownViewable {

    var dropDownViewHeight: CGFloat {
        let factor = elements.count < DropDownConstants.numberOfRowsToShow ? elements.count : DropDownConstants.numberOfRowsToShow
        let height = dropDownView.tableView.rowHeight != UITableView.automaticDimension ? dropDownView.tableView.rowHeight : dropDownView.tableView.estimatedRowHeight
        return CGFloat(factor) * height // TODO: Improve calculation
    }
}

// MARK: - Internal - For Properties Observers
extension DropDownViewable {
    
    func dropDownOffsetChanged() {
        guard let constraints = dropDownView.superview?.constraints else { return }
        
        let attribute: NSLayoutConstraint.Attribute = showDirection == .down ? .top : .bottom
        let verticalConstraint = constraints.first(where: {
            return $0.secondItem is DropDownView && $0.firstAttribute == attribute
        })
        verticalConstraint?.constant = dropDownOffset
    }
    
    func elementsChanged() {
        dropDownView.elements = elements
        dropDownView.reload()
    }
    
    func selectedElementchanged(fromOldValue oldValue:DropDownItemable?) {
        dropDownView.select(item: selectedElement, animated: false)
        whenShowScrollToSelection = oldValue == nil
    }

}

// MARK: - Internal - Setups
extension DropDownViewable where Self: UIView {
    
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
        
        dropDownView.elements = elements
        dropDownView.selectedItemAction = { [unowned self] (item, index) in
            self.selectedElement = item
            self.selectedItemAction?(item, index)
            self.delegate?.dropDown(self, didSelectItem: item, atIndex: index)
            
            if self.dismissOption != .manual {
                self.dismissDropDown()
            }
        }
    }
    
}

// MARK: - Internal - User Tapped in View
extension DropDownViewable where Self:UIView {
    
    func didTapped() {
        // Add constraints if needed
        dropDownView.attach(to: self)
        
        if !dropDownView.isShowing {
            showDropDown()
        } else {
            // If dissmis option is manual do not dismiss
            if dismissOption != .manual {
                dismissDropDown()
            }
        }
    }
    
}

// MARK: - Public
public extension DropDownViewable where Self:UIView {
    
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
        // Scroll to Selected Item
        if whenShowScrollToSelection {
            dropDownView.scrollToSelectedIndex()
        }
        
        // Manage corners
        layer.maskedCorners = dropDownView.direction == .down ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        delegate?.dropDown(self, willShowWithDirection: self.dropDownView.direction)
        dropDownView.show(animations: { [unowned self] in
            // Rotate arrow view as aditional animation
            if self.arrowImageView != nil {
                self.arrowImageView!.transform = self.arrowImageView!.transform.rotated(by: CGFloat.pi)
            }
            
        }, completion: { [unowned self] _ in
            self.delegate?.dropDown(self, didShowWithDirection: self.dropDownView.direction)
        })
    }
    
    func dismissDropDown() {
        whenShowScrollToSelection = false
        
        delegate?.dropDown(self, willDismissWithDirection: self.dropDownView.direction)
        dropDownView.dismiss(animations: { [unowned self] in
            // Rotate arrow view
            if self.arrowImageView != nil {
                self.arrowImageView!.transform = self.arrowImageView!.transform.rotated(by: CGFloat.pi)
            }
            
            // Manage corners
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
        }, completion: { [unowned self] _ in
            self.delegate?.dropDown(self, didDismissWithDirection: self.dropDownView.direction)
        })
    }
}

