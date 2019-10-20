//
//  SignUpViewController.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 20/10/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    
//    MARK: Outlets
    @IBOutlet weak var nicknameOu: UITextField!
    @IBOutlet weak var emailOu: UITextField!
    @IBOutlet weak var passwordOu: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
