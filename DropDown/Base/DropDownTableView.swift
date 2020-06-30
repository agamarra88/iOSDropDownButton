//
//  DropDownTableView.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/26/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

public class DropDownTableView: UIView {
    
    // MARK: - Constants
    private let cellIdentifier = "DropDownCellIdentifier"
    
    // MARK: - Properties - Inspectables / Configuration
    public var cornerRadius: CGFloat = 0 {
        didSet {
            tableView.layer.cornerRadius = cornerRadius
        }
    }
    public var borderWidth: CGFloat = 0 {
        didSet {
            tableView.layer.borderWidth = borderWidth
        }
    }
    public var borderColor: UIColor = .clear {
        didSet {
            tableView.layer.borderColor = borderColor.cgColor
        }
    }
    public var separatorStyle:UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            tableView.separatorStyle = separatorStyle
        }
    }
    public var shadowColor: UIColor = .clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    public var shadowOpacity: CGFloat = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    public var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    public var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    public var maskedCorners: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] {
        didSet {
            tableView.layer.maskedCorners = maskedCorners
        }
    }
    
    var dismissOption: DropDownDismissOption = .automatic
    var dropDownOffset: CGFloat = 0
    var direction: DropDownDirection = .down
    var isShowing: Bool = false
    
    // MARK: - Properties
    fileprivate var heightConstraint: NSLayoutConstraint?
    fileprivate var backgroundTapGesture: UITapClosureGestureRecognizer?
    
    public var tableView: UITableView!
    public var elements: [DropDownItemable] = []
    public var selectedItemAction: dropDownSelectedItemAction?
    
    // MARK: - Constructors
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTableView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupTableView()
    }
    
    // MARK: - Private
    private func setupView() {
        backgroundColor = .clear
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = Float(shadowOpacity)
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.maskedCorners = maskedCorners
        
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

// MARK: - Public - Register Cells
public extension DropDownTableView {
    
    func registerReusable(nibCell nib:UINib,
                          withRowHeight rowHeight:CGFloat = UITableView.automaticDimension,
                          estimatedRowHeight:CGFloat = 45) {
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = estimatedRowHeight
    }
    
    func registerReusable(cell cellClass:AnyClass,
                          withRowHeight rowHeight:CGFloat = UITableView.automaticDimension,
                          estimatedRowHeight:CGFloat = 45) {
        tableView.register(cellClass, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = estimatedRowHeight
    }
    
}

// MARK: - Public - Operations
public extension DropDownTableView {
    
    func reload(keepSelection: Bool = true) {
        let selectedIndexes = tableView.indexPathsForSelectedRows
        tableView.reloadData()
        
        if keepSelection,
            let indexes = selectedIndexes {
            for index in indexes {
                tableView.selectRow(at: index, animated: false, scrollPosition: .none)
            }
        }
    }
    
    func select(item:DropDownItemable?, animated:Bool) {
        if let selectedItem = item {
            // Select a row
            guard let row = elements.firstIndex(where: { return selectedItem.isEqual(to: $0) }) else {
                return
            }
            let indexPath = IndexPath(row: row, section: 0)
            tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
            
        } else {
            // Remove Selection
            if let selectedIndex = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndex, animated: animated)
            }
            
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    func scrollToSelectedIndex() {
        if let selectedIndex = tableView.indexPathForSelectedRow {
            tableView.scrollToRow(at: selectedIndex, at: .top, animated: false)
        }
    }
}

// MARK: - UITableViewDataSource
extension DropDownTableView: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

// MARK: - UITableViewDelegate
extension DropDownTableView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = elements[indexPath.row]
        selectedItemAction?(item, indexPath.row)
    }
    
}

// MARK: - Attach to View
extension DropDownTableView {
    
    public func attach(to view: UIView) {
        
        // Validate if view is attached. If the constraint is NILL then it is not attached
        guard heightConstraint == nil else { return }
        
        let superView = bestSuperViewForDropDown(fromView: view)
        superView.addSubview(self)
        
        // Add the dropdown to the ViewController view and set constraitns
        direction = canShowDropDown(in: superView, from: view) ? .down : .up
        constraint(to: view, forDirection: direction)
        registerDismissGesture(to: view)
        
        // Forcing the layout because then an animation will come. With this the view will be located in the right place for the animation
        layoutIfNeeded()
    }
    
    fileprivate func bestSuperViewForDropDown(fromView view: UIView) -> UIView {
        var parentView = view
        while !canShowDropDown(in: parentView, from: view) {
            guard let superview = parentView.superview else {
                return parentView
            }
            parentView = superview
        }
        return parentView
    }
    
    fileprivate func canShowDropDown(in superView: UIView, from attachedView: UIView) -> Bool {
        let pontInSuperView = superView.convert(attachedView.frame.origin, to: nil)
        let finalHeight = pontInSuperView.y + attachedView.frame.height + dropDownViewHeight + dropDownOffset
        return superView.frame.height > finalHeight
    }
    
    fileprivate func constraint(to view: UIView, forDirection direction: DropDownDirection) {
        // Add DropDownView to the view stack
        translatesAutoresizingMaskIntoConstraints = false
        
        // Define vertical constraint according to the direction
        var verticalConstraint: NSLayoutConstraint
        if direction == .down {
            verticalConstraint = topAnchor.constraint(equalTo: view.bottomAnchor, constant: dropDownOffset)
        } else {
            verticalConstraint = bottomAnchor.constraint(equalTo: view.topAnchor, constant: -dropDownOffset)
        }
        
        // Add Constratins
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([heightConstraint!,
                                     verticalConstraint,
                                     leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                                     trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)])
    }
    
    fileprivate func registerDismissGesture(to superView: UIView) {
        if backgroundTapGesture == nil {
            
            //            // Finding the best superview for the dissmiss gesture
            //            var parentView: UIView? = superView
            //            while !(parentView is UIScrollView) && parentView?.superview != nil {
            //                parentView = parentView?.superview
            //            }
            //
            //            // Register gesture
            //            backgroundTapGesture = UITapClosureGestureRecognizer(action: { [weak self] _ in
            //                guard let weakself = self else { return }
            //                if weakself.isShowing && weakself.dismissOption == .automatic {
            //                    weakself.dismissDropDown()
            //                }
            //            })
            //            backgroundTapGesture?.delegate = superView // TODO: TEMPORAL
            //            parentView?.isUserInteractionEnabled = true
            //            parentView?.addGestureRecognizer(backgroundTapGesture!)
        }
    }
    
    
    
    var dropDownViewHeight: CGFloat {
        let factor = elements.count < DropDownConstants.numberOfRowsToShow ? elements.count : DropDownConstants.numberOfRowsToShow
        let height = tableView.rowHeight != UITableView.automaticDimension ? tableView.rowHeight : tableView.estimatedRowHeight
        return CGFloat(factor) * height // TODO: Improve calculation
    }
}

// MARK: - Dismiss & Show
extension DropDownTableView {
    
    public func show(animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        isShowing = true
        
        // Animate and show DropDownView (TableView)
        heightConstraint?.constant = dropDownViewHeight
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            
            // Execute other animations if needed
            animations?()
            
            // Update constraint and frame while we animate
            self.layoutIfNeeded()
            let factor: CGFloat = self.direction == .down ? 1 : -1
            self.center.y += factor * self.frame.height / 2
            
            }, completion: completion)
    }
    
    public func dismiss(animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        isShowing = false
        
        // Animate and hide DropDownView (TableView)
        heightConstraint?.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            
            // Execute other animations if needed
            animations?()
            
            // Update constraint and frame while we animate
            let factor: CGFloat = self.direction == .down ? 1 : -1
            self.center.y -= factor * self.frame.height / 2
            self.layoutIfNeeded()
            
            }, completion: completion)
    }
}

