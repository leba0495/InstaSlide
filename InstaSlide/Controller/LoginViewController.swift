//
//  LoginViewController.swift
//  iSlide
//
//  Created by Luis Brito on 8/5/21.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField! {
        didSet {
            userNameField.layer.cornerRadius = 10
            userNameField.tag = 1
            userNameField.delegate = self
        }
    }
    @IBOutlet weak var passwordField: UITextField! {
        didSet {
            passwordField.layer.cornerRadius = 10
            passwordField.tag = 2
            passwordField.delegate = self
        }
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.layer.cornerRadius = 10
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Previously used UserDefaults to implement logged in after app's restarts but UD is not use for authentication so it's not secure.
//    override func viewDidAppear(_ animated: Bool) {
//        if UserDefaults.standard.bool(forKey: "userLoggedIn") == true {
//            self.performSegue(withIdentifier: "loginSegue", sender: self)
//        }
//    }
    
    @IBAction func onSignIn(_ sender: Any) {
        let userName = userNameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: userName, password: password) { (pfUser, error) in
            if (pfUser != nil ){
//                UserDefaults.standard.setValue(true, forKey: "userLoggedIn")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        
        let user = PFUser()
        user.username = userNameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (sucess, error) in
            if sucess {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate {
    // To move to the next field after pressing 'Return' key.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
