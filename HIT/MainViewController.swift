//
//  MainViewController.swift
//  HIT
//
//  Created by Nathan Melehan on 12/6/15.
//  Copyright © 2015 Nathan Melehan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    
    
    //
    //
    //
    //
    // MARK: - Properties
    
    var mantraList = [String]()
    var currentMantraIndex: Int?
    
    
    
    //
    //
    //
    //
    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentMantraTextView: UITextView!
    
    
    
    //
    //
    //
    //
    // MARK: - IBActions
    
    @IBAction func addMantraButtonPressed(sender: AnyObject) {
        mantraList.append("New Mantra")
        self.tableView.reloadData()
    }
    
    
    
    //
    //
    //
    //
    // MARK: - Constants
    
    struct StoryboardConstants {
        static let MantraTableViewCellReuseIdentifier = "Mantra Table View Cell"
    }
    
    
    
    //
    //
    //
    //
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //
    //
    //
    //
    // MARK: - UITextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let resultRange = text.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet(), options: NSStringCompareOptions.BackwardsSearch)
        if text.characters.count == 1 && resultRange != nil {
            textView.resignFirstResponder()
            return false
        }
        else {
            return true
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        // save to list
        if let index = currentMantraIndex where index < mantraList.count {
            mantraList[index] = textView.text
            self.tableView.reloadData()
        }
    }
    
    
    
    //
    //
    //
    //
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mantraList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardConstants.MantraTableViewCellReuseIdentifier, forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = mantraList[indexPath.row]

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentMantraIndex = indexPath.row
        currentMantraTextView.text = mantraList[indexPath.row]
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
