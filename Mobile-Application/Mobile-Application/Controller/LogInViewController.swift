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
    
    
//  MARK:  Outlets
    @IBOutlet weak var facebookSignInBtn: FBLoginButton!
    @IBOutlet weak var googleSignInBtn: UIButton!
    
    
//    Variables
    
    
//    Constants
    let userDefault = UserDefaults.standard
    
    
//    MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Google
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
        
        
//        Facebook (TO DO: cambiare posizione)
        facebookSignInBtn.delegate = self
//        let loginButton = FBLoginButton()
//        loginButton.delegate = self
//        loginButton.center = view.center
//        self.view.addSubview(loginButton)
        
        
		// button customization
		googleSignInBtn.addTarget(self, action: #selector(btnSignInPressed), for: UIControl.Event.touchUpInside)
		facebookSignInBtn.frame = CGRect(x: 0, y: 0, width: 280, height: 50)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if userDefault.bool(forKey: "usersignedin"){
            self.performSegue(withIdentifier: "Segue_To_SignIn_Social", sender: self)
        }
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
    
//    MARK: Facebook Delegate
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
            
        }else{
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error == nil{
                    self.userDefault.set(true, forKey: "usersignedin")
                    self.userDefault.synchronize()
                    self.performSegue(withIdentifier: "Segue_To_Signin_Social", sender: self)
                }else{
                    print(error?.localizedDescription)
                }
                
                let newUserReference = Firestore.firestore().collection("Users").document((authResult?.user.uid)!)    // <-- create a document, with the user id from Firebase Auth

                newUserReference.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        print("Document data: \(dataDescription)")
                        newUserReference.updateData([
                                        "ID": authResult?.user.uid,
                                        "nickname": authResult?.user.displayName,
                                        "email": authResult?.user.email,
                                        "registrazione" : "Facebook",
                                        "timestamp": Timestamp()
                        //                "image": result?.user.photoURL
                                        ])
                    } else {
                        print("Document does not exist")
                        newUserReference.setData([
                                        "ID": authResult?.user.uid,
                                        "nickname": authResult?.user.displayName,
                                        "email": authResult?.user.email,
                                        "registrazione" : "Facebook",
                                        "timestamp": Timestamp()
                        //                "image": result?.user.photoURL
                                        ])
                    }
                }
                
            }
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        return
    }

    
    
//    MARK: Actions
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "SignIn_With_Email", sender: self)
        
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "SignUp_With_Email", sender: self)
    }
    
    
//    Serve per il Sign Out: NON CANCELLARE
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {

    }
    
	@objc func btnSignInPressed() {
        GIDSignIn.sharedInstance().signIn()
    }
    
}
