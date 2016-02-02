//
//  CardTableViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 12/24/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

class CardTableViewController: UIViewController, CardTableViewDelegate
{
    
    
    
    //
    //
    //
    //
    // MARK: - Outlets
    
    @IBOutlet weak var cardTableView: CardTableView!
    
    
    
    //
    //
    //
    //
    // MARK: - CardTableViewDelegate
    
    func numberOfCardsInCardTableView(cardTableView: CardTableView) -> Int {
        return 3
    }
    
    func cardTableView(cardTableView: CardTableView, annotationAtIndex index: Int) -> CardAnnotation {
        let mantra = Mantra(id: index, name: "test title")
        
        return mantra
    }
    
    func nextCardPullLocationForCardTableView(cardTableView: CardTableView) -> CGPoint {
        return CGPoint(x: cardTableView.bounds.width/2, y: cardTableView.cardHeight/2)
    }
    
    
    
    //
    //
    //
    //
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardTableView.delegate = self
    }
    
//    override func viewDidLayoutSubviews() {
//        
//    }
}
