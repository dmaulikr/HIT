//
//  NSRange+Helpers.swift
//  HIT
//
//  Created by Nathan Melehan on 2/14/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

extension NSRange
{
    func swiftRange() -> Range<Int>
    {
        return (self.location..<self.location+self.length)
    }
}