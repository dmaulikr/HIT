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
    
    let dataSource: MantraDataSource = UserMantraDataManager.sharedManager
    
    override func viewDidLayoutSubviews() {
//        print("viewDidLayoutSubviews, collapsedCardStackView.frame: \(collapsedCardStackView.frame)")
        if collapsedCardStackView.delegate == nil {
            collapsedCardStackView.delegate = self
        }
    }
    
    func pulledCard() -> TestCardView?
    {
//        let card = CardView()
//        card.annotation = dataSource.currentMantra
//        let cardColor = UIColor.randomColor().colorWithAlphaComponent(0.2)
//        card.cardTitleView.backgroundColor = cardColor
//        card.xibView.backgroundColor = cardColor
//        return card
        
//        return nil
        
        let card = TestCardView()
        let cardColor = UIColor.randomColor().colorWithAlphaComponent(1.0)
        card.backgroundColor = cardColor
        return card
    }
    
    func cardsDisplayedInStack() -> [TestCardView]
    {
//        return (1..<5)
//            .map { dataSource.mantraWithId($0)! }
//            .map {
//                let card = CardView()
//                card.annotation = $0
//                let cardColor = UIColor.randomColor()
//                card.cardTitleView.backgroundColor = cardColor
//                card.xibView.backgroundColor = cardColor
//                return card
//            }
        
        return (1..<5)
            .map { dataSource.mantraWithId($0)! }
            .map { mantra in
                let card = TestCardView()
                let cardColor = UIColor.randomColor()
                card.backgroundColor = cardColor
                return card
            }
    }
}
