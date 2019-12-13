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
        
        guard let nickname = nicknameOu.text, let mail = emailOu.text, let pw = passwordOu.text, !nickname.isEmpty, !mail.isEmpty, !pw.isEmpty else {
            let alert = UIAlertController(title: "Campo Vuoto", message: "Riempire tutti i campi prima di continuare!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            //style: .cancel

            self.present(alert, animated: true)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password){ (result, error) in
            if let x = error {
                let err = x as NSError
                switch err.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    print("wrong password")
                case AuthErrorCode.invalidEmail.rawValue:
                    print("invalid email")
                case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                    print("accountExistsWithDifferentCredential")
                    let alert = UIAlertController(title: "Wrong Credentials", message: "The Account exists with different credentials", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true)
                case AuthErrorCode.emailAlreadyInUse.rawValue: //<- Your Error
                    print("email is alreay in use")
                    let alert = UIAlertController(title: "Email Already Used", message: "Use another email", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true)
                case AuthErrorCode.weakPassword.rawValue:
                    print("weak password")
                    let alert = UIAlertController(title: "Weak Password", message: "The password must be 6 characters long or more", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                default:
                    print("unknown error: \(err.localizedDescription)")
                    
                }
               //return
            } else {
               //User Created
               print("User Created")
               // Sing In user
               self.SignInUser(email: email, password: password)
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
            
            self.createUserDatabase(userId: (user?.user.uid)!)
            //Handle Error sulla documentazione e mostrare all'utente i vari errori quando capitano
        }
    }
    
    func createUserDatabase (userId: String) {
        let newUserReference = Firestore.firestore().collection("Users").document(userId)    // <-- create a document, with the user id from Firebase Auth

        newUserReference.setData([
            "ID": userId,
            "nickname": nicknameOu.text!,
            "email": emailOu.text!,
            "password": passwordOu.text!,
            "registrazione": "Email e Password",
            "timestamp": Timestamp()
            ])
    }
    
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        self.createUser(email: emailOu.text!, password: passwordOu.text!)
    }
    
    
}
