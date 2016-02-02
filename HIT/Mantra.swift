//
//  Mantra.swift
//  HIT
//
//  Created by Nathan Melehan on 12/24/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import Foundation

struct Mantra
{
    init(id: Int, name: String) {
        self._id = id
        self._name = name
    }
    
    private var _id: Int
    private var _name: String
    
    var id: Int {
        get {
            return self.id
        }
    }
    var name: String {
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }
}