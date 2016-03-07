//
//  SettingsViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 3/6/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController,
    UIViewControllerTransitioningDelegate
{
    @IBAction func backPressed(sender: AnyObject) {
        print("back pressed")
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
