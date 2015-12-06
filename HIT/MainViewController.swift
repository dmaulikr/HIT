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
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var mantraList: [String] {
        get {
            if defaults.arrayForKey(ModelKeys.MantraList) as? [String] == nil {
                defaults.setObject([String](), forKey: ModelKeys.MantraList)
            }
            return defaults.arrayForKey(ModelKeys.MantraList) as! [String]
        }
        set {
            defaults.setObject(newValue, forKey: ModelKeys.MantraList)
        }
    }
    
    var currentMantraIndex: Int? {
        get {
            return defaults.valueForKey(ModelKeys.CurrentMantraIndex) as? Int
        }
        set {
            if let index = newValue {
                defaults.setInteger(index, forKey: ModelKeys.CurrentMantraIndex)
            }
            else {
                defaults.removeObjectForKey(ModelKeys.CurrentMantraIndex)
            }
        }
    }
    
    
    
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
        mantraList.append("")
        currentMantraIndex = mantraList.count-1
        
        currentMantraTextView.text = ""
        currentMantraTextView.becomeFirstResponder()
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
        
        if let index = currentMantraIndex where index < mantraList.count
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
        
        if let index = currentMantraIndex where index < mantraList.count
        {
            if textView.text.characters.count == 0
            {
                mantraList.removeAtIndex(index)
                currentMantraIndex = nil
            }
            else
            {
                mantraList[index] = textView.text
            }
    
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

}
