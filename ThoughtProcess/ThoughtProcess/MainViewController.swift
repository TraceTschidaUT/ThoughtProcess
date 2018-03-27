//
//  MainViewController.swift
//  ThoughtProcess
//
//  Created by Gabriela Dudzic on 3/27/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Move to the login view controller
        guard let controller = UIStoryboard(name: "login", bundle: nil).instantiateInitialViewController() as? LoginViewController else { return }
        
        // Present the controller
        self.present(controller, animated: true, completion: nil)
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
