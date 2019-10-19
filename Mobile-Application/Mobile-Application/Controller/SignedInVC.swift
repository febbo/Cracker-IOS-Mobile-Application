//
//  SignedInVC.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 17/10/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FacebookLogin
import FBSDKLoginKit


class SignedInVC: UIViewController {

//    Outlets
    @IBOutlet weak var emailOu: UILabel!
    
    
//    Variables
    
    
//    Constants
    let userDefault = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.setHidesBackButton(true, animated: false)

        guard let email = Auth.auth().currentUser?.email else {return}
        emailOu.text = email
        // Do any additional setup after loading the view.
    }
    

//    Actions
    @IBAction func signOutBtnPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            try GIDSignIn.sharedInstance()?.signOut()
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.synchronize()
            LoginManager().logOut()
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func GoOn(_ sender: Any) {
        self.performSegue(withIdentifier: "Segue_Go_On", sender: self)
    }
    
    
}
