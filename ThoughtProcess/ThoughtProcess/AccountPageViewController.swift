//
//  AccountPageViewController.swift
//  ThoughtProcess
//
//  Created by Gabriela Dudzic on 4/7/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

class AccountPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    var userArray:[User] = []

   
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var dob: UILabel!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    var editFirstName : String  = ""
    var editLastName : String = ""
    var editUsername : String = ""
    var editEmail : String = ""
    var editPassword : String = ""
    
    
    let db = DbContext.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let defaults = UserDefaults.standard
        guard let stringID = defaults.string(forKey: "id") else { return }
        
        // Convert the string ID to UUID
        guard let id = UUID(uuidString: stringID) else { return }
        
        guard let user = db.fetchUser(id: id) else { return }
        
        //placeholders should show current info
        firstName.placeholder = user.firstName
        lastName.placeholder = user.lastName
        username.placeholder = user.username
        email.placeholder = user.email
        password.placeholder = user.password
        confirmPassword.placeholder = user.password
        
        //Convert date to string
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date())
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "dd-MMM-yyyy"
        // again convert your date to string
        let myStringafd = formatter.string(from: user.dateOfBirth!)
        
        dob.text = myStringafd
        
        guard let profileImage = user.profilePicture as? UIImage else { return }
        profilePicture.image = profileImage
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    

    @IBAction func changePicture(_ sender: UIButton) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(pickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func save(_ sender: UIButton) {
       
        if firstName.text != "" {
            editFirstName = firstName.text!
        } else{
            editFirstName = firstName.placeholder!
        }
        
        if lastName.text != "" {
            editLastName = lastName.text!
        } else{
            editLastName = lastName.placeholder!
        }
        
        if username.text != "" {
            editUsername = username.text!
        } else{
            editUsername = username.placeholder!
        }
        
        if password.text != "" {
            editPassword = password.text!
        } else{
            editPassword = password.placeholder!
        }
        
        if email.text != "" {
            editEmail = email.text!
        } else{
            editEmail = email.placeholder!
        }
        
        // Get the id
        let defaults = UserDefaults.standard
        guard let idString =  defaults.string(forKey: "id") else { return }
        let id = UUID(uuidString: idString)
        
        guard let picture = self.profilePicture.image else { return }
        
        db.editAccount(id: id!, firstName: editFirstName, lastName: editLastName, username: editUsername, password: editPassword, email: editEmail, profilePicture: picture)
        
        self.dismiss(animated: true, completion: nil)
       
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.profilePicture.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: UIButton) {
        
        UserDefaults.standard.set(false, forKey: "loggedIn")
        UserDefaults.standard.set("", forKey: "id")
        
        // Create a View Controller and present it
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
