//
//  NSIndexPath+Helpers.swift
//  HIT
//
//  Created by Nathan Melehan on 1/10/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

extension NSIndexPath {
    func nextItem() -> NSIndexPath {
        return NSIndexPath(forItem: self.item + 1, inSection: self.section)
    }
}