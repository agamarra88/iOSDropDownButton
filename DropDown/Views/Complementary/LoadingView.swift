//
//  LoadingView.swift
//  DropDown
//
//  Created by Arturo Gamarra on 7/4/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    // MARK: - Properties
    var activityIndicator:UIActivityIndicatorView!

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLoadingView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLoadingView()
    }
    
    // MARK: - Override
    override var isHidden: Bool {
        didSet {
            if isHidden {
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.startAnimating()
            }
        }
    }
    
    // MARK: - Private
    private func setupLoadingView() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
