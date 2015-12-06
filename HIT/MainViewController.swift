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
    
//    var mantraList = [String]()
//    var currentMantraIndex: Int?
    
    
    
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
        let defaults = NSUserDefaults.standardUserDefaults()
        var mantraList = defaults.arrayForKey(ModelKeys.MantraList) as! [String]
        mantraList.append("")
        defaults.setInteger(mantraList.count-1, forKey: ModelKeys.CurrentMantraIndex)
        defaults.setObject(mantraList, forKey: ModelKeys.MantraList)
        currentMantraTextView.text = ""
        currentMantraTextView.becomeFirstResponder()
        
//        self.tableView.reloadData()
    }
    
    
    
    //
    //
    //
    //
    // MARK: - Constants
    
    struct StoryboardConstants {
        static let MantraTableViewCellReuseIdentifier = "Mantra Table View Cell"
    }
    
    struct ModelKeys {
        static let MantraList = "HIT.ModelKeys.MantraList"
        static let CurrentMantraIndex = "HIT.ModelKeys.CurrentMantraIndex"
    }
    
    
    
    //
    //
    //
    //
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.arrayForKey(ModelKeys.MantraList) == nil
        {
            defaults.setObject([String](), forKey: ModelKeys.MantraList)
        }
            
        let mantraList = defaults.arrayForKey(ModelKeys.MantraList) as! [String]
        if  let index = defaults.valueForKey(ModelKeys.CurrentMantraIndex) as? Int
            where index < mantraList.count
        {
            currentMantraTextView.text = mantraList[index]
        }
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
        let defaults = NSUserDefaults.standardUserDefaults()
        var mantraList = defaults.arrayForKey(ModelKeys.MantraList) as! [String]
        
        if  let index = defaults.valueForKey(ModelKeys.CurrentMantraIndex) as? Int
            where index < mantraList.count
        {
            if textView.text.characters.count == 0
            {
                mantraList.removeAtIndex(index)
            }
            else
            {
                mantraList[index] = textView.text
            }
            
            defaults.setObject(mantraList, forKey: ModelKeys.MantraList)
            defaults.removeObjectForKey(ModelKeys.CurrentMantraIndex)
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
        let mantraList = NSUserDefaults.standardUserDefaults().arrayForKey(ModelKeys.MantraList) as! [String]
        return mantraList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardConstants.MantraTableViewCellReuseIdentifier, forIndexPath: indexPath)

        // Configure the cell...
        let mantraList = NSUserDefaults.standardUserDefaults().arrayForKey(ModelKeys.MantraList) as! [String]
        cell.textLabel?.text = mantraList[indexPath.row]

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(indexPath.row, forKey: ModelKeys.CurrentMantraIndex)
        let mantraList = defaults.arrayForKey(ModelKeys.MantraList) as! [String]
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
