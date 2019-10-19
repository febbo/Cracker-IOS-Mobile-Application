//
//  LogInViewController.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 11/10/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class LogInViewController: UIViewController, LoginButtonDelegate{
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            print("Ciaooooooooooooooo")
            return
            
        }else{
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
              if error == nil{
                print("Weeeeeeeeeeeeeeeeee")
                self.userDefault.set(true, forKey: "usersignedin")
                self.userDefault.synchronize()
                self.performSegue(withIdentifier: "Segue_To_Signin", sender: self)
              }else{
                print(error?.localizedDescription)
              }
            }
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        return
    }
    
    
//    Outlets
    @IBOutlet weak var emailOu: UITextField!
    @IBOutlet weak var passwordOu: UITextField!
    
    
//    Variables
    
    
    
//    Constants
    let userDefault = UserDefaults.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Google
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
        
        
//        Facebook (TO DO: cambiare posizione)
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.center = view.center
        self.view.addSubview(loginButton)
        
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if userDefault.bool(forKey: "usersignedin"){
            self.performSegue(withIdentifier: "Segue_To_Signin", sender: self)
        }
    }
    
    
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
                self.performSegue(withIdentifier: "Segue_To_Signin", sender: self)
            } else if error?._code == AuthErrorCode.userNotFound.rawValue {
                self.createUser(email: email, password: password)
            } else{
                print(error)
                print(error?.localizedDescription)
            }
            
            
            //Handle Error sulla documentazione e mostrare all'utente i vari errori quando capitano
        }
    }
    
    
    
//    Actions
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        SignInUser(email: emailOu.text!, password: passwordOu.text!)
        
    }
    
    
}
