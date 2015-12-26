//
//  UIColor+Helpers.swift
//  HIT
//
//  Created by Nathan Melehan on 12/25/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import Foundation

extension UIColor {
    class func randomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}