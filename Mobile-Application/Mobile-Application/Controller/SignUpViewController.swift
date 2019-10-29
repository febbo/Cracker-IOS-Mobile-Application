//
//  SignUpViewController.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 20/10/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class SignUpViewController: UIViewController {

    
//    MARK: Outlets
    @IBOutlet weak var nicknameOu: UITextField!
    @IBOutlet weak var emailOu: UITextField!
    @IBOutlet weak var passwordOu: UITextField!
    
    
//    Constants
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //    MARK: Email/Password Delegate
    func createUser(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password){ (result, error) in
            if error == nil{
                //User Created
                print("User Created")
                // Sing In user
                self.SignInUser(email: email, password: password)
            } else{
                print(error?.localizedDescription)
            }
        }
    }
    
    func SignInUser(email: String, password:String){
        Auth.auth().signIn(withEmail: email, password: password){ (user,error) in
            if error == nil{
                //Signed In
                print("User Signed In")
                self.userDefault.set(true, forKey: "usersignedin")
                self.userDefault.synchronize()
                self.performSegue(withIdentifier: "Segue_To_SignUp", sender: self)
            } else if error?._code == AuthErrorCode.userNotFound.rawValue {
                self.createUser(email: email, password: password)
            } else{
                print(error)
                print(error?.localizedDescription)
            }
            
            
            //Handle Error sulla documentazione e mostrare all'utente i vari errori quando capitano
        }
    }
    
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        self.createUser(email: emailOu.text!, password: passwordOu.text!)
    }
    
    
}
