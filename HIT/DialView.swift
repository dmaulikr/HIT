//
//  DialView.swift
//  HIT
//
//  Created by Nathan Melehan on 1/26/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

@IBDesignable class DialView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var shapeLayer = CAShapeLayer()
    
    @IBInspectable var dialLineWidth: CGFloat = 10 {
        didSet {
            setupDialPath()
        }
    }
    
    @IBInspectable var dialColor: CGColor = UIColor.blueColor().CGColor {
        didSet {
            setupDialPath()
        }
    }
    
    func setupDialPath() {
        shapeLayer.frame = self.bounds
        shapeLayer.strokeColor = dialColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = dialLineWidth
        
        let containingRect = CGRect(
            x: dialLineWidth/2,
            y: dialLineWidth/2,
            width: shapeLayer.bounds.width - dialLineWidth,
            height: shapeLayer.bounds.height - dialLineWidth)
        shapeLayer.path = UIBezierPath(ovalInRect: containingRect).CGPath
    }
    
    func setupDialLayer() {
        setupDialPath()
        
        self.layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        setupDialPath()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupDialLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupDialLayer()
    }

}
