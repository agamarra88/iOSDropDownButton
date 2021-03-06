//
//  DropDownTableView.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/26/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

public protocol DropDownTableViewDelegate: class {
    
    func dropDown(_ sender:DropDownTableView, didSelectItem item:DropDownItemable, atIndex index:Int)
    
    func dropDown(_ sender:DropDownTableView, willShowWithDirection direction:DropDownDirection)
    func dropDown(_ sender:DropDownTableView, didShowWithDirection direction:DropDownDirection)
    func dropDown(_ sender:DropDownTableView, willDismissWithDirection direction:DropDownDirection)
    func dropDown(_ sender:DropDownTableView, didDismissWithDirection direction:DropDownDirection)
    
    func dropDown(_ sender:DropDownTableView, loadPage page:Int)
}

public extension DropDownTableViewDelegate {
    
    func dropDown(_ sender:DropDownTableView, willShowWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownTableView, didShowWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownTableView, willDismissWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownTableView, didDismissWithDirection direction:DropDownDirection) { }
    func dropDown(_ sender:DropDownTableView, loadPage page:Int) { }
    
}

public class DropDownTableView: UIView {
    
    public struct PagingConfiguration {
        
        public var pullToRefreshEnabled: Bool
        public var infiniteScrollEnabled: Bool
        public var page: Int = 0
        
        public var enabled: Bool {
            return pullToRefreshEnabled || infiniteScrollEnabled
        }
    }
    
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
    public var offset: CGFloat = 0 {
        didSet {
            guard let constraints = superview?.constraints else { return }
            
            let attribute: NSLayoutConstraint.Attribute = direction == .down ? .top : .bottom
            let verticalConstraint = constraints.first(where: {
                return $0.secondItem is DropDownView && $0.firstAttribute == attribute
            })
            verticalConstraint?.constant = offset
        }
    }
    public var isShowing: Bool = false {
        didSet {
            backgroundTapGesture?.isEnabled = isShowing
        }
    }
    public var direction: DropDownDirection = .down {
        didSet {
            tableView.layer.maskedCorners = direction == .down ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    public var dismissOption: DropDownDismissOption = .automatic
    public var preferredHeight: CGFloat = DropDownConstants.defaultHeight   // If it is set default. The size will be calculated by RowToDisplay
    public var rowToDisplay: Int = DropDownConstants.numberOfRowsToDisplay  // Helps to calculate the DropDownHeight
    public var elements: [DropDownItemable] = []
    public var selectedElement: DropDownItemable? {
        didSet {
            whenShowScrollToSelection = oldValue == nil
        }
    }
    public var paging: PagingConfiguration = PagingConfiguration(pullToRefreshEnabled: false, infiniteScrollEnabled: false) {
        didSet {
            registerRefreshControl()
            registerFooterLoadingView()
        }
    }
    
    // MARK: - Properties - Actions
    public weak var delegate: DropDownTableViewDelegate?
    public var selectedItemAction: DropDownSelectedItemAction?
    public var loadPageAction: DropDownLoadPageAction?
    
    // MARK: - Properties - Private
    private weak var ownerView: UIView?
    private var tableView: UITableView!
    private var heightConstraint: NSLayoutConstraint?
    private var backgroundTapGesture: UITapClosureGestureRecognizer?
    private var whenShowScrollToSelection: Bool = false
    private var maskedCorners: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] {
        didSet {
            tableView.layer.maskedCorners = maskedCorners
        }
    }
    
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
}

// MARK: - Private
fileprivate extension DropDownTableView {
    
    var dropDownHeight: CGFloat {
        return preferredHeight != DropDownConstants.defaultHeight ? preferredHeight : dynamicHeight
    }
    
    var dynamicHeight: CGFloat {
        let count = paging.enabled && elements.count == 0 ? rowToDisplay : elements.count
        let factor = count < rowToDisplay ? elements.count : rowToDisplay
        let height = tableView.rowHeight != UITableView.automaticDimension ? tableView.rowHeight : tableView.estimatedRowHeight
        return CGFloat(factor) * height // TODO: Improve calculation
    }
    
    func setupView() {
        backgroundColor = .clear
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = Float(shadowOpacity)
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.prefetchDataSource = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.maskedCorners = maskedCorners
        
        addSubview(tableView)
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                                     tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                                     tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)])
        
        tableView.separatorStyle = separatorStyle
        registerReusable(cell: UITableViewCell.self)
        registerRefreshControl()
        registerFooterLoadingView()
    }
    
    func registerRefreshControl() {
        if !paging.pullToRefreshEnabled {
            tableView.refreshControl = nil
            return
        }
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    func registerFooterLoadingView() {
        if !paging.infiniteScrollEnabled {
            tableView.tableFooterView = UIView()
            return
        }
        let loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 40))
        loadingView.isHidden = true
        tableView.tableFooterView = loadingView
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
    
    func select(item: DropDownItemable?, animated: Bool) {
        selectedElement = item
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

// MARK: - Attach to View
extension DropDownTableView {
    
    public func attach(to view: UIView) {
        ownerView = view
        
        // Validate if view is attached. If the constraint is NILL then it is not attached
        guard heightConstraint == nil, let viewController = view.viewController else { return }
        
        viewController.view.addSubview(self)
        
        // Add the dropdown to the ViewController view and set constraitns
        direction = direction(in: viewController.view, displayingFrom: view)
        constraint(to: view, forDirection: direction)
        registerDismissGesture(to: viewController.view)
        
        // Forcing the layout because then an animation will come. With this the view will be located in the right place for the animation
        layoutIfNeeded()
    }
    
    fileprivate func direction(in superView: UIView, displayingFrom attachedView: UIView) -> DropDownDirection {
        let pontInSuperView = attachedView.convert(attachedView.frame.origin, to: superView)
        let finalHeight = pontInSuperView.y + attachedView.frame.height + dropDownHeight + offset
        return superView.frame.height > finalHeight ? .down : .up
    }
    
    fileprivate func constraint(to view: UIView, forDirection direction: DropDownDirection) {
        // Add DropDownView to the view stack
        translatesAutoresizingMaskIntoConstraints = false
        
        // Define vertical constraint according to the direction
        var verticalConstraint: NSLayoutConstraint
        if direction == .down {
            verticalConstraint = topAnchor.constraint(equalTo: view.bottomAnchor, constant: offset)
        } else {
            verticalConstraint = bottomAnchor.constraint(equalTo: view.topAnchor, constant: -offset)
        }
        
        // Add Constratins
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([heightConstraint!,
                                     verticalConstraint,
                                     leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                                     trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)])
    }
    
    fileprivate func registerDismissGesture(to superView: UIView) {
        // Add background tapGesture if DismissOption is automatic
        if backgroundTapGesture == nil && dismissOption == .automatic {
            
            backgroundTapGesture = UITapClosureGestureRecognizer(action: { [weak self] _ in
                guard let weakself = self
                    , let ownerView = weakself.ownerView as? DropDownViewable
                    , weakself.isShowing else {
                        return
                }
                ownerView.dismissDropDown()
            })
            backgroundTapGesture?.cancelsTouchesInView = false
            backgroundTapGesture?.delegate = self
            
            superView.isUserInteractionEnabled = true
            superView.addGestureRecognizer(backgroundTapGesture!)
        }
    }
}

// MARK: - Public - Dismiss & Show
public extension DropDownTableView {
    
    func show(animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        isShowing = true
        
        // Scroll to Selected Item
        if whenShowScrollToSelection {
            scrollToSelectedIndex()
        }
        
        // Animate and show DropDownView (TableView)
        delegate?.dropDown(self, willShowWithDirection: direction)
        heightConstraint?.constant = dropDownHeight
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            
            // Execute other animations if needed
            animations?()
            
            // Update constraint and frame while we animate
            self.layoutIfNeeded()
            let factor: CGFloat = self.direction == .down ? 1 : -1
            self.center.y += factor * self.frame.height / 2
            
            }, completion: { done in
                self.delegate?.dropDown(self, didShowWithDirection: self.direction)
                completion?(done)
        })
    }
    
    func dismiss(animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        isShowing = false
        whenShowScrollToSelection = false
        
        // Animate and hide DropDownView (TableView)
        delegate?.dropDown(self, willDismissWithDirection: direction)
        heightConstraint?.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [unowned self] in
            
            // Execute other animations if needed
            animations?()
            
            // Update constraint and frame while we animate
            let factor: CGFloat = self.direction == .down ? 1 : -1
            self.center.y -= factor * self.frame.height / 2
            self.layoutIfNeeded()
            
            }, completion: { done in
                self.delegate?.dropDown(self, didDismissWithDirection: self.direction)
                completion?(done)
        })
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
            customCell.configureBy(item: item)
        } else {
            cell.textLabel?.text = item.description
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension DropDownTableView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedElement = elements[indexPath.row]
        selectedItemAction?(selectedElement!, indexPath.row)
        delegate?.dropDown(self, didSelectItem: selectedElement!, atIndex: indexPath.row)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DropDownTableView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // If false the background gesture won't work; if true it will get fired
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // If the touch occurs in a DropDownViewable
        // The background gesture is enable if isShowing is false.
        if let ownerView = touch.view as? DropDownViewable {
            return !ownerView.isShowing
        }
        
        // If the touch occurs in a DropDownTableView
        if let dropDownView = touch.view?.superView(of: DropDownTableView.self) {
            return dropDownView != self
        }
        
        // If is showing from a textfield do not dismiss when it scroll in the tableView
        if touch.view?.canBecomeFirstResponder != true {
            touch.window?.endEditing(true)
        }
        return true
    }
}

// MARK: - UITableViewDataSourcePrefetching & Paging
extension DropDownTableView: UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row >= (elements.count - 2) }) {
            guard let loadingView = tableView.tableFooterView as? LoadingView else { return }
            loadingView.isHidden = false
            paging.page += 1
            loadPageAction?(self, paging.page)
            delegate?.dropDown(self, loadPage: paging.page)
        }
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        paging.page = 1
        loadPageAction?(self, paging.page)
        delegate?.dropDown(self, loadPage: paging.page)
    }
    
    public func stopLoading(type: DropDownLoadingType? = nil) {
        if type == nil || type == .refresh {
            tableView.refreshControl?.endRefreshing()
        }
        if type == nil || type == .infinite {
            guard let loadingView = tableView.tableFooterView as? LoadingView else { return }
            loadingView.isHidden = true
        }
    }
    
}
