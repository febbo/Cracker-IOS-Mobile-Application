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

class LogInViewController: UIViewController {
    
    override func viewDidLoad() {
      super.viewDidLoad()

    GIDSignIn.sharedInstance()?.presentingViewController = self
    GIDSignIn.sharedInstance().signIn()

      // TODO(developer) Configure the sign-in button look/feel
      // ...
    }
    
}
