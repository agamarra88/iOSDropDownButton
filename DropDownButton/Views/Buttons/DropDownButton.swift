//
//  DropDownButton.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/25/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

protocol DropDownItemable: CustomStringConvertible {
    
}

extension String:DropDownItemable {
    
}

protocol DropDownViewCellable:class {

    func configureBySetting(item:DropDownItemable)
}

@IBDesignable class DropDownButton: UIButton {
    
    // MARK: - Constants
    let numberOfRowsToShow = 3
    
    // MARK: - Properties - Inspectables / Configuration
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            dropDownView.layer.cornerRadius = cornerRadius
        }
    }
    var separatorStyle:UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            dropDownView.separatorStyle = separatorStyle
        }
    }
    
    // MARK: - Properties
    private var dropDownViewHeightConstraint: NSLayoutConstraint?
    private(set)var isOpen: Bool = false
    
    var dropDownView: DropDownView!
    var elements: [DropDownItemable] = [] {
        didSet {
            dropDownView.elements = elements
            dropDownView.tableView.reloadData()
        }
    }
    var selectedElement:CustomStringConvertible? {
        didSet {
            if let element = selectedElement {
                setTitle(element.description, for: .normal)
            } else {
                setTitle("", for: .normal) // TODO: show inital title
            }
        }
    }
    
    // MARK: - Calculated Properties
    private var dropDownViewHeight:CGFloat {
        let factor = elements.count < numberOfRowsToShow ? elements.count : numberOfRowsToShow
        return CGFloat(factor) * dropDownView.tableView.estimatedRowHeight // TODO: Improve calculation
    }
    
    // MARK: - Constructors
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        setupDropDownView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        setupDropDownView()
    }
    
    // MARK: - Private
    private func setupButton() {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    private func setupDropDownView() {
        dropDownView = DropDownView()
        dropDownView.clipsToBounds = true
        dropDownView.layer.cornerRadius = cornerRadius
        dropDownView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        dropDownView.separatorStyle = separatorStyle
        
        if let currentSuperView = superview {
            constraintDropDownView(toSuperView: currentSuperView)
        }
        
        dropDownView.elements = elements
        dropDownView.rowSelectedAction = { [unowned self] (item, IndexPath) in
            self.selectedElement = item
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
    
    // MARK: - Public
    func registerReusable(nibCell nib:UINib, withRowHeight rowHeight:CGFloat = UITableView.automaticDimension, estimatedRowHeight:CGFloat = 45) {
        dropDownView.registerReusable(nibCell: nib, withRowHeight: rowHeight, estimatedRowHeight: estimatedRowHeight)
    }
    
    func registerReusable(cell cellClass:AnyClass, withRowHeight rowHeight:CGFloat = UITableView.automaticDimension, estimatedRowHeight:CGFloat = 45) {
        dropDownView.registerReusable(cell: cellClass, withRowHeight: rowHeight, estimatedRowHeight: estimatedRowHeight)
    }
    
    func openDropDown() {
        isOpen = true
        
        // Manage corners
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Animate and show DropDownView (TableView)
        dropDownViewHeightConstraint?.constant = dropDownViewHeight
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.dropDownView.layoutIfNeeded()
            self.dropDownView.center.y += self.dropDownView.frame.height / 2
            
        }, completion: nil)
    }
    
    func closeDropDown() {
        isOpen = false
        
        // Manage corners
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        dropDownViewHeightConstraint?.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            self.dropDownView.center.y -= self.dropDownView.frame.height / 2
            self.dropDownView.layoutIfNeeded()
            
            }, completion: nil)
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

// MARK: - DropDownView
class DropDownView: UIView {
    
    typealias Model = DropDownItemable
    
    // MARK: - Definitions
    typealias rowSelectedClosure = (DropDownItemable, IndexPath) -> Void
    
    // MARK: - Constants
    let cellIdentifier = "DropDownCellIdentifier"
    
    // MARK: - Properties - Inspectables / Configuration
    var separatorStyle:UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            tableView.separatorStyle = separatorStyle
        }
    }
    
    // MARK: - Properties
    var tableView: UITableView!
    var elements: [DropDownItemable] = []
    var rowSelectedAction: rowSelectedClosure?
    
    // MARK: - Constructors
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Private
    private func setupView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubview(tableView)
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                                     tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                                     tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)])
        
        tableView.separatorStyle = separatorStyle
        tableView.tableFooterView = UIView()
        registerReusable(cell: UITableViewCell.self)
    }
    
}

// MARK: - Public
extension DropDownView {
    
    func registerReusable(nibCell nib:UINib, withRowHeight rowHeight:CGFloat = UITableView.automaticDimension, estimatedRowHeight:CGFloat = 45) {
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = estimatedRowHeight
    }
    
    func registerReusable(cell cellClass:AnyClass, withRowHeight rowHeight:CGFloat = UITableView.automaticDimension, estimatedRowHeight:CGFloat = 45) {
        tableView.register(cellClass, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = estimatedRowHeight
    }
    
}

// MARK: - DropDownView - UITableViewDataSource
extension DropDownView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = elements[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let customCell = cell as? DropDownViewCellable {
            customCell.configureBySetting(item: item)
        } else {
            cell.textLabel?.text = item.description
        }
        return cell
    }
    
}

// MARK: - DropDownView - UITableViewDelegate
extension DropDownView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = elements[indexPath.row]
        rowSelectedAction?(item, indexPath)
    }
    
}
