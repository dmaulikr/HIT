//
//  PulledCardViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 2/2/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class CollapsedCardStackViewController: UIViewController, CollapsedCardStackViewDelegate {

    @IBOutlet weak var collapsedCardStackView: CollapsedCardStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    // Data controller
    
    let dataSource: UserMantraDataManager = UserMantraDataManager.sharedManager
    
    override func viewDidLayoutSubviews()
    {
        if collapsedCardStackView.delegate == nil
        {
            collapsedCardStackView.dataSource = dataSource
            collapsedCardStackView.delegate = self
        }
    }
    
    
    
    
    func pulledCard() -> Int
    {
        return 7
    }
    
    func cardAtTopOfStack() -> Int
    {
        return 5
    }
    
    func numberOfItemsToDisplayInStack() -> Int
    {
        return 5
    }
}
