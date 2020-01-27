//
//  DropDownTableView.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 1/26/20.
//  Copyright © 2020 Vector. All rights reserved.
//

import UIKit

class DropDownTableView: UIView {
    
    // MARK: - Constants
    private let cellIdentifier = "DropDownCellIdentifier"
    
    // MARK: - Properties - Inspectables / Configuration
    var cornerRadius: CGFloat = 0 {
        didSet {
            tableView.layer.cornerRadius = cornerRadius
        }
    }
    var borderWidth: CGFloat = 0 {
        didSet {
            tableView.layer.borderWidth = borderWidth
        }
    }
    var borderColor: UIColor = .clear {
        didSet {
            tableView.layer.borderColor = borderColor.cgColor
        }
    }
    var separatorStyle:UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            tableView.separatorStyle = separatorStyle
        }
    }
    var shadowColor: UIColor = .clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    var shadowOpacity: CGFloat = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    var shadowRadius:CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    // MARK: - Properties
    var tableView: UITableView!
    var elements: [DropDownItemable] = []
    var selectedItemAction: dropDownSelectedItemAction?
    
    // MARK: - Constructors
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupTableView()
    }
    
    // MARK: - Private
    private func setupView() {
        backgroundColor = .clear
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
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
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
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
extension DropDownTableView {
    
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

// MARK: - UITableViewDelegate
extension DropDownTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = elements[indexPath.row]
        selectedItemAction?(item, indexPath.row)
    }
    
}
