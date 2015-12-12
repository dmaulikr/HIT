//
//  AutoLayoutTestViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 12/11/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

class AutoLayoutTestViewController: UIViewController {
    
    
    
    //
    //
    //
    //
    // MARK: - Outlets
    
    @IBOutlet weak var theView: UIView!
    
    @IBOutlet var leftConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var rightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    
    
    //
    //
    //
    //
    // MARK: - Actions
    
    @IBAction func setNeedsLayoutButtonPressed() {
        self.view.setNeedsLayout()
    }
    
    @IBAction func dropConstraintsButtonPressed() {
        theView.translatesAutoresizingMaskIntoConstraints = true
        leftConstraint.active = false
        rightConstraint.active = false
        topConstraint.active = false
        bottomConstraint.active = false
    }
    
    @IBAction func addConstraintsBackButtonPressed() {
        theView.translatesAutoresizingMaskIntoConstraints = false
        leftConstraint.active = true
        rightConstraint.active = true
        topConstraint.active = true
        bottomConstraint.active = true
    }
    
    @IBAction func handlePanGestureRecognizer(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
//        theView.center = CGPoint(x: theView.center.x + translation.x,
//            y: theView.center.y + translation.y)
        let rads = translation.x * CGFloat(M_PI/180)
        let transform = CGAffineTransformRotate(theView.transform, rads);
        theView.transform = transform;
        sender.setTranslation(CGPointZero, inView: theView)
    }
    
    //
    //
    //
    //
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
