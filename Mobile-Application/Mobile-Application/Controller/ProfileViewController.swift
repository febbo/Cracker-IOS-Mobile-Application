//
//  ProfileViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 11/10/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FacebookLogin
import FBSDKLoginKit

class ProfileViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
//    Outlets
    @IBOutlet weak var imageOU: UIImageView!
    @IBOutlet weak var nicknameOu: UILabel!

	@IBOutlet weak var seriesCollection: UICollectionView!
    
//    Constants
    let userDefault = UserDefaults.standard
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.backgroundColor = UIColor(named: "DarkGreen")

			navigationController?.navigationBar.standardAppearance = appearance
			navigationController?.navigationBar.compactAppearance = appearance
			navigationController?.navigationBar.scrollEdgeAppearance = appearance
			navigationItem.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
		}
		
		seriesCollection.delegate = self
		seriesCollection.dataSource = self
        
        guard let name = Auth.auth().currentUser?.displayName  else {return}
        nicknameOu.text = name
        
        guard let imageURL = Auth.auth().currentUser?.photoURL else {return}
        imageOU.load(url: imageURL)

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeriesCell", for: indexPath) as! SeriesCollectionViewCell
        cell.seriesImage.image = UIImage(named: "series")
        
        return cell
    }
    
    
//    Actions
    @IBAction func signOutBtnPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            try GIDSignIn.sharedInstance()?.signOut()
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.synchronize()
            LoginManager().logOut()
            self.performSegue(withIdentifier: "unwindToLogIn", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    

}
