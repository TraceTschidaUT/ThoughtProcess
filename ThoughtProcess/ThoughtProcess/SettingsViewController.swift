//
//  SettingsViewController.swift
//  ThoughtProcess
//
//  Created by Gabriela Dudzic on 4/17/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var homeCollectionSegmented: UISegmentedControl!
    
    // Controller Properties
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeCollectionSegmented.selectedSegmentIndex = defaults.integer(forKey: "collectionCellType")
        
    }
    
    @IBAction func changeHomeLook(_ sender: UISegmentedControl) {
        
        defaults.set(sender.selectedSegmentIndex, forKey: "collectionCellType")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
