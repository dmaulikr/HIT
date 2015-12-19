//
//  XibDesignedView.swift
//  HIT
//
//  Created by Nathan Melehan on 12/19/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

class XibDesignedView: UIView {
    
    // facilitates embedding this xib-designed view inside another xib or storyboard
    @IBOutlet weak var xibView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    func xibSetup() {
        NSBundle(forClass: self.dynamicType).loadNibNamed("CardView", owner: self, options: nil)
        self.addSubview(self.xibView)
        
        // pin xibView to self
        self.xibView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.pinItem(self, toItem: self.xibView, withAttribute: .Top).active = true
        NSLayoutConstraint.pinItem(self, toItem: self.xibView, withAttribute: .Leading).active = true
        NSLayoutConstraint.pinItem(self, toItem: self.xibView, withAttribute: .Trailing).active = true
        NSLayoutConstraint.pinItem(self, toItem: self.xibView, withAttribute: .Bottom).active = true
    }

}
