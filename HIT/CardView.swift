//
//  CardPresentation.swift
//  HIT
//
//  Created by Nathan Melehan on 2/16/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit


class CardView: UIView
{
    // These should be implemented by the subclass
    func presentCollapsedView() { }
    func presentStackedView() { }
    func presentPulledView() { }
}