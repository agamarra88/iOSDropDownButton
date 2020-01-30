//
//  DropDownViewable.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/27/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

// MARK: - Constants
enum DropDownConstants {
    
    static let numberOfRowsToShow = 3
    static let imageViewWidth:CGFloat = 40
    
}

protocol DropDownViewDelegate:class {
    
    func dropDown(_ sender:DropDownViewable, didSelectItem item:DropDownItemable, atIndex index:Int)
    
    func dropDown(_ sender:DropDownViewable, willShowWithDirection direction:DropDownDirection)
    func dropDown(_ sender:DropDownViewable, didShowWithDirection direction:DropDownDirection)
    func dropDown(_ sender:DropDownViewable, willDismissWithDirection direction:DropDownDirection)
    func dropDown(_ sender:DropDownViewable, didDismissWithDirection direction:DropDownDirection)
    
}

extension DropDownViewDelegate {

    func dropDown(_ sender:DropDownViewable, willShowWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownViewable, didShowWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownViewable, willDismissWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownViewable, didDismissWithDirection direction:DropDownDirection) { }
    
}

protocol DropDownViewable: UIGestureRecognizerDelegate {
    
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
    
    var backgroundTapGesture: UITapClosureGestureRecognizer? { get set }
    var dropDownViewHeightConstraint: NSLayoutConstraint? { get set }
    var showDirection: DropDownDirection { get set }
    var whenShowScrollToSelection: Bool { get set }
    var isShowing: Bool { get set }
    
    var delegate:DropDownViewDelegate? { get set }
    var selectedItemAction: dropDownSelectedItemAction? { get set }
    
    var arrowImageView: UIImageView? { get set }
    var dropDownView: DropDownTableView { get set }
    var elements: [DropDownItemable] { get set }
    var selectedElement:DropDownItemable? { get set }
}


// MARK: - Calculated Properties
extension DropDownViewable {

    var dropDownViewHeight:CGFloat {
        let factor = elements.count < DropDownConstants.numberOfRowsToShow ? elements.count : DropDownConstants.numberOfRowsToShow
        let height = dropDownView.tableView.rowHeight != UITableView.automaticDimension ? dropDownView.tableView.rowHeight : dropDownView.tableView.estimatedRowHeight
        return CGFloat(factor) * height // TODO: Improve calculation
    }
}

// MARK: - Internal - For Properties Observers
extension DropDownViewable {
    
    func dropDownOffsetChanged() {
        guard let constraints = dropDownView.superview?.constraints else { return }
        
        let attribute:NSLayoutConstraint.Attribute = showDirection == .down ? .top : .bottom
        let verticalConstraint = constraints.first(where: {
            return $0.secondItem is DropDownView && $0.firstAttribute == attribute
        })
        verticalConstraint?.constant = dropDownOffset
    }
    
    func showDirectionChanged() {
        dropDownView.maskedCorners = showDirection == .down ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func isShowingChanged() {
        backgroundTapGesture?.isEnabled = isShowing
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
extension DropDownViewable where Self:UIView {
    
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
        
        if let currentSuperView = superview {
            let parentView = bestSuperViewForDropDown(fromView: currentSuperView)
            constraintDropDownView(toSuperView: parentView)
            registerdDismissGesture(toSuperView: parentView)
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
    
    fileprivate func canShowDropDown(inSuperView superView:UIView) -> Bool {
        let pontInSuperView = superView.convert(frame.origin, to: nil)
        let finalHeight = pontInSuperView.y + frame.height + dropDownViewHeight + dropDownOffset
        return superView.frame.height > finalHeight
    }
    
    fileprivate func bestSuperViewForDropDown(fromView view:UIView) -> UIView {
        var parentView = view
        while !canShowDropDown(inSuperView: parentView) {
            guard let superview = parentView.superview else {
                return parentView
            }
            parentView = superview
        }
        return parentView
    }
    
    fileprivate func constraintDropDownView(toSuperView superView:UIView) {
        // Add DropDownView to the view stack
        dropDownView.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(dropDownView)
        
        // Define DropDown direction
        showDirection = canShowDropDown(inSuperView: superView) ? DropDownDirection.down : DropDownDirection.up
        var verticalConstraint:NSLayoutConstraint
        if showDirection == .down {
            verticalConstraint = dropDownView.topAnchor.constraint(equalTo: bottomAnchor, constant: dropDownOffset)
        } else {
            verticalConstraint = dropDownView.bottomAnchor.constraint(equalTo: topAnchor, constant: -dropDownOffset)
        }
        
        // Add Constratins
        dropDownViewHeightConstraint = dropDownView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([dropDownViewHeightConstraint!,
                                     verticalConstraint,
                                     dropDownView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     dropDownView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)])
    }
    
    fileprivate func registerdDismissGesture(toSuperView superView:UIView) {
        if backgroundTapGesture == nil {
            
            // Finding the best superview for the dissmiss gesture
            var parentView:UIView? = superView
            while !(parentView is UIScrollView) && parentView?.superview != nil {
                parentView = parentView?.superview
            }
            
            // Register gesture
            backgroundTapGesture = UITapClosureGestureRecognizer(action: { [weak self] _ in
                guard let weakself = self else { return }
                if weakself.isShowing && weakself.dismissOption == .automatic {
                    weakself.dismissDropDown()
                }
            })
            backgroundTapGesture?.delegate = self
            parentView?.isUserInteractionEnabled = true
            parentView?.addGestureRecognizer(backgroundTapGesture!)
        }
    }
    
    func didTapped() {
        // Add constraints if needed
        if dropDownViewHeightConstraint == nil,
            let currentSuperView = superview {
            let parentView = bestSuperViewForDropDown(fromView: currentSuperView)
            constraintDropDownView(toSuperView: parentView)
            registerdDismissGesture(toSuperView: parentView)
            
            // Forcing the layout because then an animation will come. With this the view will be located in the right place for the animation
            dropDownView.layoutIfNeeded()
        }
        
        if !isShowing {
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
extension DropDownViewable where Self:UIView {
    
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
        isShowing = true
        
        // Scroll to Selected Item
        if whenShowScrollToSelection {
            dropDownView.scrollToSelectedIndex()
        }
        
        // Manage corners
        layer.maskedCorners = showDirection == .down ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        // Animate and show DropDownView (TableView)
        dropDownViewHeightConstraint?.constant = dropDownViewHeight
        delegate?.dropDown(self, willShowWithDirection: showDirection)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            // Rotate arrow view
            if self.arrowImageView != nil {
                self.arrowImageView!.transform = self.arrowImageView!.transform.rotated(by: CGFloat.pi)
            }
            
            // Update constraint and frame while we animate
            self.dropDownView.layoutIfNeeded()
            let factor:CGFloat = self.showDirection == .down ? 1 : -1
            self.dropDownView.center.y += factor * self.dropDownView.frame.height / 2
            
            }, completion: { [unowned self] _ in
                self.delegate?.dropDown(self, didShowWithDirection: self.showDirection)
        })
    }
    
    func dismissDropDown() {
        isShowing = false
        whenShowScrollToSelection = false
        
        // Animate and hide DropDownView (TableView)
        dropDownViewHeightConstraint?.constant = 0
        delegate?.dropDown(self, willDismissWithDirection: showDirection)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            // Rotate arrow view
            if self.arrowImageView != nil {
                self.arrowImageView!.transform = self.arrowImageView!.transform.rotated(by: CGFloat.pi)
            }
            
            // Manage corners
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            // Update constraint and frame while we animate
            let factor:CGFloat = self.showDirection == .down ? 1 : -1
            self.dropDownView.center.y -= factor * self.dropDownView.frame.height / 2
            self.dropDownView.layoutIfNeeded()
            
            }, completion: { [unowned self] _ in
                self.delegate?.dropDown(self, didDismissWithDirection: self.showDirection)
        })
    }
    
}

// MARK: - Methods for UIGestureRecognizerDelegate
extension DropDownViewable where Self:UIView {
    
    func isAnOutside(touch:UITouch) -> Bool {
        let isInDropDown = isTouch(touch, inView: dropDownView)
        let isInSelf = isTouch(touch, inView: self)
        return !isInDropDown && !isInSelf
    }
    
    private func isTouch(_ touch:UITouch, inView view:UIView) -> Bool {
        let location = touch.location(in: view)
        let inXAxis = view.bounds.origin.x <= location.x && location.x <= view.bounds.width
        let inYAxis = view.bounds.origin.y <= location.y && location.y <= view.bounds.height
        return inXAxis && inYAxis
    }
}
