//
//  UserMantraDataManager.swift
//  HIT
//
//  Created by Nathan Melehan on 2/1/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

@objc class UserMantraDataManager: NSObject, MantraDataSource
{
    static let sharedManager = UserMantraDataManager()
    
    var idCounter = 1
    
    override init() {
        for i in 0..<10 {
            userMantras[i] = Mantra(id: i, name: "Mantra \(i)")
        }
        
        idCounter = 10
        
        currentUserMantra = userMantras[0]
    }
    
    
    //
    // MARK: - Internal state
    
    var currentUserMantra: Mantra?
    var userMantras = [Int : Mantra]()
    
    
    //
    // MARK: - MantraDataSource protocol
    
    var currentMantra: Mantra? {
        get {
            return currentUserMantra
        }
        set {
            currentUserMantra = newValue
        }
    }
    
    var mantras: [Mantra] {
        get {
            return [Mantra](userMantras.values).sort { $0.id < $1.id }
        }
    }
    
    func mantraWithId(id: Int) -> Mantra?
    {
        return userMantras[id]
    }
    
    func addMantraWithName(name: String)
    {
        let newMantra = Mantra(id: idCounter, name: name)
        idCounter += 1
        userMantras[newMantra.id] = newMantra
    }
    
    func removeMantra(mantra: Mantra)
    {
        userMantras.removeValueForKey(mantra.id)
    }
    
    func updateMantra(newValue: Mantra) {
        userMantras[newValue.id] = newValue
    }
}