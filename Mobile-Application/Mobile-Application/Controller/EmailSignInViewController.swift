//
//  EmailSignInViewController.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 20/10/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class EmailSignInViewController: UIViewController {

//     MARK: Outlets
    @IBOutlet weak var emailOu: UITextField!
    @IBOutlet weak var passwordOu: UITextField!
    
//    Constants
    let userDefault = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if userDefault.bool(forKey: "usersignedin"){
            self.performSegue(withIdentifier: "Segue_To_Signin", sender: self)
        }
    }
    
    
//    MARK: Email/Password Delegate
//      func createUser(email: String, password: String){
//          Auth.auth().createUser(withEmail: email, password: password){ (result, error) in
//              if error == nil{
//                  //User Created
//                  print("User Created")
//                  // Sing In user
//                  self.SignInUser(email: email, password: password)
//              } else{
//                  print(error?.localizedDescription)
//              }
//          }
//      }
      
      func SignInUser(email: String, password:String){
          Auth.auth().signIn(withEmail: email, password: password){ (user,error) in
            if error == nil{
                  //Signed In
                print("User Signed In")
                self.userDefault.set(true, forKey: "usersignedin")
                self.userDefault.synchronize()
                self.performSegue(withIdentifier: "Segue_To_SignIn", sender: self)
                
            } else if error?._code == AuthErrorCode.userNotFound.rawValue {
                print("Utente non registrato")
                let alert = UIAlertController(title: NSLocalizedString("User not registered", comment: ""), message: NSLocalizedString("Register to continue!", comment: ""), preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default, handler: nil))

                self.present(alert, animated: true)
            } else if error?._code == AuthErrorCode.wrongPassword.rawValue {
                let alert = UIAlertController(title: NSLocalizedString("Wrong password", comment: ""), message: NSLocalizedString("The password is wrong", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true)
            } else{
                print(error)
                print(error?.localizedDescription)
            }
              
              
              //Handle Error sulla documentazione e mostrare all'utente i vari errori quando capitano
          }
      }
    
    
    
//    MARK: Actions
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        SignInUser(email: emailOu.text!, password: passwordOu.text!)
        
    }
    
}
