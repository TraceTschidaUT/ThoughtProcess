//
//  LoginViewController.swift
//  ThoughtProcess
//
//  Created by Gabriela Dudzic on 3/21/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let Db = DbContext.sharedInstance

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var paswordTextField: UITextField!
    @IBOutlet weak var messageText: UILabel!
    
    
    
    @IBAction func loginClicked(_ sender: Any) {
        
        // Get the username and password
        guard let password = paswordTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        
        guard let _ = Db.fetchUser(userName: username, password: password) else {
            
            messageText.text = "User not found"
            return
        }
            
        // Create a View Controller and present it
        guard let controller = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as?HomeViewController else { return }
        
        let navigationController = UINavigationController(rootViewController: controller)
        
        // Present the controller
        self.present(navigationController, animated: true, completion: nil)

    }
    
    @IBAction func createAccountClicked(_ sender: UIButton) {
        // Create a View Controller and present it
        guard let controller = UIStoryboard(name: "createAccount", bundle: nil).instantiateInitialViewController() as? createAccountViewController else { return }
        
        // Present the controller
        self.present(controller, animated: true, completion: nil)
    }
    
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
