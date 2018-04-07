//
//  createAccountViewController.swift
//  ThoughtProcess
//
//  Created by Gabriela Dudzic on 3/21/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit
import CoreData

class createAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let Db = DbContext.sharedInstance
    
    //Core data object
    var users = [NSManagedObject]()
    var managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var profileImage: UIImageView!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var firstNametxt: UITextField!
    @IBOutlet weak var lastNametxt: UITextField!
    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    @IBOutlet weak var confirmPasswordtxt: UITextField!
    @IBOutlet weak var errorMessagetxt: UILabel!
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    
    var dob = Date()
    
    @objc func dob(_ sender: UIDatePicker) {
        print(sender.date)
        dob = sender.date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dobDatePicker.addTarget(self, action: #selector(dob(_:)), for: UIControlEvents.valueChanged)
        self.dobDatePicker.datePickerMode = UIDatePickerMode.date
//        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func createAccountClicked(_ sender: Any) {
        
        guard let firstname = firstNametxt.text else { return }
        guard let lastname = lastNametxt.text else { return }
        guard let username = usernametxt.text else { return }
        guard let password = passwordtxt.text else { return }
        guard let confirmPassword = confirmPasswordtxt.text else { return }
        guard let email = emailtxt.text else { return }
        guard let proiflePicture = profileImage.image else { return }
        
        if(password == confirmPassword){
        
            Db.createUser(date: self.dob, firstName: firstname, lastName: lastname, username: username, password: password, email: email, profilePicture: proiflePicture)
        
            // Create a View Controller and present it
            guard let controller = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as?HomeViewController else { return }
            
            let navigationController = UINavigationController(rootViewController: controller)
        
            // Present the controller
            self.present(navigationController, animated: true, completion: nil)
        } else{
            errorMessagetxt.text = "Passwords do not match"
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadPhoto(_ sender: UIButton) {
        
        var pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(pickerController, animated: true, completion: nil)
        
        
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
