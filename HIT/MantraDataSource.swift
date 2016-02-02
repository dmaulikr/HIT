//
//  MantraDataSource.swift
//  HIT
//
//  Created by Nathan Melehan on 2/1/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

protocol MantraDataSource
{
    var currentMantra: Mantra? { get set }
    var mantras: [Mantra] { get }
    
    func addMantraWithName(name: String)
    func removeMantra(mantra: Mantra)
    func updateMantra(newValue: Mantra)
}