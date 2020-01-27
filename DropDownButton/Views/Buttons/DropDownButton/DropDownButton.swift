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
    func dropDownButtonWillDismissDropDown(_ sender:DropDownButton)
    func dropDownButtonDidDismissDropDown(_ sender:DropDownButton)
    
}

extension DropDownButtonDelegate {
    
    func dropDownButtonWillShowDropDown(_ sender:DropDownButton) {}
    func dropDownButtonDidShowDropDown(_ sender:DropDownButton) {}
    func dropDownButtonWillDismissDropDown(_ sender:DropDownButton) {}
    func dropDownButtonDidDismissDropDown(_ sender:DropDownButton) {}
    
}

enum DropDownDirection {
    
    case up
    case down
    
}

enum DropDownDismissOption {
    
    case automatic  // No tap is needed to dismiss the drop down. As soon as the user interact with anything else than the drop down, the drop down is dismissed
    case onTap      // A tap inseide the drop down is needed to dismiss it
    case manual     // The drop down can only be dismissed manually (by code)
    
}

@IBDesignable class DropDownButton: UIButton {
    
    // MARK: - Constants
    private let numberOfRowsToShow = 3
    
    // MARK: - Properties - Inspectables & Configuration
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            dropDownView.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        willSet {
            dropDownBorderWidth = newValue
        }
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor = .clear {
        willSet {
            dropDownBorderColor = newValue
        }
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var dropDownBorderWidth: CGFloat = 0 {
        didSet {
            dropDownView.borderWidth = dropDownBorderWidth
        }
    }
    @IBInspectable var dropDownBorderColor: UIColor = .clear {
        didSet {
            dropDownView.borderColor = dropDownBorderColor
        }
    }
    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            dropDownView.shadowColor = shadowColor
        }
    }
    @IBInspectable var shadowOpacity: CGFloat = 0 {
        didSet {
            dropDownView.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            dropDownView.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var shadowRadius:CGFloat = 0 {
        didSet {
            dropDownView.shadowRadius = shadowRadius
        }
    }
    var separatorStyle:UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            dropDownView.separatorStyle = separatorStyle
        }
    }
    var dismissOption:DropDownDismissOption = .automatic
    
    // MARK: - Properties
    private var backgroundTapGesture: UITapGestureRecognizer?
    private var dropDownViewHeightConstraint: NSLayoutConstraint?
    private var placeholder: String = ""
    private var showDirection: DropDownDirection = .down
    private var whenShowScrollToSelection:Bool = false
    private(set)var isShowing: Bool = false {
        didSet {
            let image = isShowing ? UIImage(named: "dropDownArrowUp") : UIImage(named: "dropDownArrowDown")
            arrowImageView.image = image
            
            backgroundTapGesture?.isEnabled = isShowing
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
            whenShowScrollToSelection = oldValue == nil
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
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
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
            self.delegate?.dropDownButton(self, didSelectItem: item, atIndex: index)
            
            if self.dismissOption != .manual {
                self.dismissDropDown()
            }
        }
    }
    private func canShowDropDown(inSuperView superView:UIView) -> Bool {
        let finalHeight = frame.origin.y + frame.height + dropDownViewHeight
        return superView.frame.height > finalHeight
    }
    
    private func bestSuperViewForDropDown(fromView view:UIView) -> UIView {
        var parentView = view
        while !canShowDropDown(inSuperView: parentView) {
            guard let superview = parentView.superview else {
                return parentView
            }
            parentView = superview
        }
        return parentView
    }
    
    private func constraintDropDownView(toSuperView superView:UIView) {
        // Add DropDownView to the view stack
        dropDownView.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(dropDownView)
        
        // Define DropDown direction
        showDirection = canShowDropDown(inSuperView: superView) ? DropDownDirection.down : DropDownDirection.up
        var verticalConstraint:NSLayoutConstraint
        if showDirection == .down {
            verticalConstraint = dropDownView.topAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        } else {
            verticalConstraint = dropDownView.bottomAnchor.constraint(equalTo: topAnchor, constant: 0)
        }
        
        // Add Constratins
        dropDownViewHeightConstraint = dropDownView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([dropDownViewHeightConstraint!,
                                     verticalConstraint,
                                     dropDownView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     dropDownView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)])
    }
    
    private func registerdDismissGesture(toSuperView superView:UIView) {
        if backgroundTapGesture == nil {
            
            // Finding the best superview for the dissmiss gesture
            var parentView:UIView? = superView
            while !(parentView is UIScrollView) && parentView?.superview != nil {
                parentView = parentView?.superview
            }
            
            // Register gesture
            backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
            backgroundTapGesture?.delegate = self
            parentView?.isUserInteractionEnabled = true
            parentView?.addGestureRecognizer(backgroundTapGesture!)
        }
    }
    
    // MARK: - Action
    @IBAction private func buttonTapped(_ sender:DropDownButton) {
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
    
    @IBAction private func backgroundTapped(_ recognizer:UITapGestureRecognizer) {
        if isShowing && dismissOption == .automatic {
            dismissDropDown()
        }
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
    
    func showDropDown() {
        isShowing = true
        
        // Scroll to Selected Item
        if whenShowScrollToSelection {
            dropDownView.scrollToSelectedIndex()
        }
        
        // Manage corners
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Animate and show DropDownView (TableView)
        dropDownViewHeightConstraint?.constant = dropDownViewHeight
        delegate?.dropDownButtonWillShowDropDown(self)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            self.dropDownView.layoutIfNeeded()
            
            let factor:CGFloat = self.showDirection == .down ? 1 : -1
            self.dropDownView.center.y += factor * self.dropDownView.frame.height / 2
            
        }, completion: { [unowned self] _ in
            self.delegate?.dropDownButtonDidShowDropDown(self)
        })
    }
    
    func dismissDropDown() {
        isShowing = false
        whenShowScrollToSelection = false
        
        // Manage corners
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        // Animate and hide DropDownView (TableView)
        dropDownViewHeightConstraint?.constant = 0
        delegate?.dropDownButtonWillDismissDropDown(self)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            let factor:CGFloat = self.showDirection == .down ? 1 : -1
            self.dropDownView.center.y -= factor * self.dropDownView.frame.height / 2
            self.dropDownView.layoutIfNeeded()
            
        }, completion: { [unowned self] _ in
            self.delegate?.dropDownButtonDidDismissDropDown(self)
        })
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
