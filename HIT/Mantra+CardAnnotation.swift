//
//  Mantra+CardAnnotation.swift
//  HIT
//
//  Created by Nathan Melehan on 2/1/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

extension Mantra: CardAnnotation
{
    var cardTitle: String {
        get {
            return name
        }
        set {
            name = newValue
            let manager = UserMantraDataManager.sharedManager
            manager.updateMantra(self)
        }
    }
}