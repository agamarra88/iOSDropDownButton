//
//  DropDownTextField.swift
//  DropDown
//
//  Created by Arturo Gamarra on 7/2/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

public protocol DropDownTextFieldDelegate: class {
    
    func dropDown(_ sender:DropDownTextField, filterBy text:String)
    
}

public extension DropDownTextFieldDelegate {
     
    func dropDown(_ sender:DropDownTextField, filterBy text:String) { }
    
}

@IBDesignable public class DropDownTextField: UITextField, DropDownViewable {
    
    public struct Configuration {
        
        public var isAutomatic = true
        public var ignoringCase = true
        public var trim = true
        
        func trim(text: String?) -> String? {
            let trimmedText = trim ? text?.trimmingCharacters(in: .whitespacesAndNewlines) : text
            return ignoringCase ? trimmedText?.lowercased() : trimmedText
        }
        
        func does(text:String, contains str:String) -> Bool {
            let aText = ignoringCase ? text.lowercased() : text
            let aStr = ignoringCase ? str.lowercased() : str
            return aText.contains(aStr)
        }
    }
    
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
    
    // MARK: - Properties - DropDownViewable
    public weak var dropDownDelegate: DropDownViewDelegate?
    public var selectedItemAction: DropDownSelectedItemAction?
    public var dropDownView: DropDownTableView
    public var arrowImageView: UIImageView?
    
    public var elements: [DropDownItemable] = [] {
        didSet {
            dropDownView.elements = elements
            dropDownView.reload(keepSelection: false)
        }
    }
    public var selectedElement: DropDownItemable? {
        get {
            dropDownView.selectedElement
        }
        set {
            dropDownView.select(item: newValue, animated: false)
            text = dropDownView.selectedElement?.description
            let _ = resignFirstResponder()
        }
    }
    
    // MARK: - Properties
    private var timer: Timer?
    public weak var filterDelegate: DropDownTextFieldDelegate?
    public var filterAction: DropDownFilterItemAction?
    public var configuration: Configuration = Configuration()
    
    // MARK: - Constructors
    public override init(frame: CGRect) {
        dropDownView = DropDownTableView()
        
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        dropDownView = DropDownTableView()
        
        super.init(coder: coder)
        setupView()
    }
}

// MARK: - Private
private extension DropDownTextField {
    
    func setupView() {
        setupDropDownViewable()
        addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    
    @objc func editingDidBegin(_ sender: UITextField) {
        dropDownView.attach(to: self)
        if !dropDownView.isShowing {
            showDropDown()
        }
    }
    
    @objc func editingChanged(_ sender: UITextField) {
        timer?.invalidate()
        timer = nil
        
        // Set timer to allow user to type other keys and filter only when he finished
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { [unowned self] _ in
            self.timer?.invalidate()
            self.timer = nil
            
            // Get Text according to configuration
            let text = self.configuration.trim(text: self.text) ?? ""
            
            // If configuration is automatic filter by descripcion
            if self.configuration.isAutomatic {
                if text.isEmpty {
                    self.reloadDropDown(by: self.elements)
                } else {
                    let filtered = self.elements.filter { self.configuration.does(text: $0.description, contains: text) }
                    self.reloadDropDown(by: filtered)
                }
            }
            
            // Call Delegates and Actions
            self.filterAction?(text)
            self.filterDelegate?.dropDown(self, filterBy: text)
        })
    }
    
    func reloadDropDown(by elements:[DropDownItemable]) {
        self.dropDownView.elements = elements
        self.dropDownView.reload(keepSelection: false)
    }
}


