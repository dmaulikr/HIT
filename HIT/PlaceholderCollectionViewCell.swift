//
//  PlaceholderCollectionViewCell.swift
//  HIT
//
//  Created by Nathan Melehan on 1/8/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

@IBDesignable class PlaceholderCollectionViewCell: UICollectionViewCell {
    var placeholderView: StatePlaceholderView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupPlaceholderView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupPlaceholderView()
    }
    
    func setupPlaceholderView() {
        placeholderView = StatePlaceholderView()
        placeholderView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        self.contentView.addSubview(placeholderView)
        
        // pin placeholderView to self
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.pinItem(self.contentView, toItem: placeholderView, withAttribute: .Top).active = true
        NSLayoutConstraint.pinItem(self.contentView, toItem: placeholderView, withAttribute: .Leading).active = true
        NSLayoutConstraint.pinItem(self.contentView, toItem: placeholderView, withAttribute: .Trailing).active = true
        NSLayoutConstraint.pinItem(self.contentView, toItem: placeholderView, withAttribute: .Bottom).active = true
    }
}
