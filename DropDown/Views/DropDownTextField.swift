//
//  DropDownTextField.swift
//  DropDown
//
//  Created by Arturo Gamarra on 7/2/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

public typealias DropDownTextFieldLoadPageAction = (DropDownTextField, String) -> Void

public protocol DropDownTextFieldDelegate: class {
    
    func dropDown(_ sender:DropDownTextField, filterBy text:String)
    
}

public extension DropDownTextFieldDelegate {
    
    func dropDown(_ sender:DropDownTextField, filterBy text:String) { }
    
}

@IBDesignable public class DropDownTextField: UITextField, DropDownViewable {
    
    public struct Configuration {
        
        public var isAutomatic = true
        public var boldCoincidences = true // Works only if automatic is true
        public var ignoringCase = true
        public var trim = true
        
        func trim(text: String?) -> String? {
            let trimmedText = trim ? text?.trimmingCharacters(in: .whitespacesAndNewlines) : text
            return ignoringCase ? trimmedText?.lowercased() : trimmedText
        }
        
        func does(text: String, contains str: String) -> Bool {
            let aText = ignoringCase ? text.lowercased() : text
            let aStr = ignoringCase ? str.lowercased() : str
            return aText.contains(aStr)
        }
        
        func range(inText text: String, of str: String) -> Range<String.Index>? {
            let aText = ignoringCase ? text.lowercased() : text
            let aStr = ignoringCase ? str.lowercased() : str
            return aText.range(of: aStr)
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
    public var loadFirstPageAction: DropDownTextFieldLoadPageAction?
    public var loadNextPageAction: DropDownTextFieldLoadPageAction?
    public var configuration: Configuration = Configuration()
    
    public var paging: DropDownTableView.PagingConfiguration {
        get {
            dropDownView.paging
        }
        set {
            dropDownView.paging = newValue
        }
    }
    
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
        dropDownView.registerReusable(cell: HighLightTableViewCell.self)
        addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        dropDownView.loadFirstPageAction = { [unowned self] _ in
            let text = self.configuration.trim(text: self.text) ?? ""
            self.loadFirstPageAction?(self, text)
        }
        dropDownView.loadNextPageAction = {  [unowned self] _ in
            let text = self.configuration.trim(text: self.text) ?? ""
            self.loadNextPageAction?(self, text)
        }
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
                let filtered = !text.isEmpty ? self.filterElements(byText: text) : self.elements
                self.reloadDropDown(by: filtered)
            }
            
            // Call Delegates and Actions
            self.filterAction?(text)
            self.filterDelegate?.dropDown(self, filterBy: text)
        })
    }
    
    func filterElements(byText text: String) -> [DropDownItemable] {
        if configuration.boldCoincidences {
            return self.elements.compactMap { (element) ->  ElementHighLight? in
                guard let range = configuration.range(inText: element.description, of: text) else { return nil }
                return ElementHighLight(element: element, range: range)
            }
            
        } else {
            return self.elements.filter({ configuration.does(text: $0.description, contains: text) })
        }
    }
    
    func reloadDropDown(by elements:[DropDownItemable]) {
        self.dropDownView.elements = elements
        self.dropDownView.reload(keepSelection: false)
    }
}

// MARK: - Pulbic
public extension DropDownTextField {
    
    func stopLoading(type: DropDownLoadingType) {
        dropDownView.stopLoading(type: type)
    }
}
