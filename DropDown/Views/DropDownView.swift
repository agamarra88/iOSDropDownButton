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
    @IBInspectable public dynamic var dropDownOffset:CGFloat = 0 {
        didSet {
            dropDownOffsetChanged()
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
    @objc dynamic public var separatorStyle:UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            dropDownView.separatorStyle = separatorStyle
        }
    }
    @objc public dynamic var dismissOption:DropDownDismissOption = .automatic
    
    // MARK: - Properties
    public var backgroundTapGesture: UITapClosureGestureRecognizer?
    
    public var whenShowScrollToSelection:Bool = false
    public var showDirection: DropDownDirection = .down {
        didSet {
            showDirectionChanged()
        }
    }
    public var isShowing: Bool = false {
        didSet {
            isShowingChanged()
        }
    }
    
    weak public var delegate:DropDownViewDelegate?
    public var selectedItemAction: dropDownSelectedItemAction?
    
    public var dropDownView: DropDownTableView
    public var arrowImageView: UIImageView?
    public var elements: [DropDownItemable] = [] {
        didSet {
            elementsChanged()
        }
    }
    public var selectedElement:DropDownItemable? {
        didSet {
            selectedElementchanged(fromOldValue: oldValue)
        }
    }
    
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
    
    // MARK: - Action
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
            !isAnOutside(touch: touch) {
            didTapped()
        }
    }
}

// MARK: - Private
private extension DropDownView {
    
    func setupView() {
        isUserInteractionEnabled = true
        setupDropDownViewable()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DropDownView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return isAnOutside(touch: touch)
    }
}
