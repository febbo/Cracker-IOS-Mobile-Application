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
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
//    Outlets
    @IBOutlet weak var imageOU: UIImageView!
    @IBOutlet weak var nicknameOu: UILabel!
	@IBOutlet weak var seriesButton: UIButton!
	
	@IBOutlet weak var seriesCollection: UICollectionView!
    
//    Constants
    let userDefault = UserDefaults.standard
    
    let User = Firestore.firestore().collection("Users").document("\((Auth.auth().currentUser?.uid)!)")
    
//    Variables
    var seriesIDs : [String] = []
    var seriesIMGs : [String] = []
    
    var dataImage : [Data] = []
    
    var reload = false
	
	override func viewDidLoad() {
        super.viewDidLoad()
        getSeries()
		
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
		
		seriesButton.addTarget(self, action: #selector(showUserSeries), for: UIControl.Event.touchUpInside)
        
        guard let name = Auth.auth().currentUser?.displayName  else {return}
        nicknameOu.text = name
        
        guard let imageURL = Auth.auth().currentUser?.photoURL else {return}
        imageOU.load(url: imageURL)

    }
    
    func getSeries(){
        User.collection("Series").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let id = data["id"] as! String
                    let image = data["image"] as! String
                    self.seriesIDs.append(id)
                    self.seriesIMGs.append(image)
                    
                    let url = URL(string: image)
                    self.dataImage.append( try! Data(contentsOf: url!))
                    
                }
                self.reload = true
                self.seriesCollection.reloadData()
            }
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if seriesIDs.count > 5{
            return 5
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        cell.button.addTarget(self, action: #selector(showSingleSeries), for: .touchUpInside)
        if self.reload == true{
            cell.seriesImage.image = UIImage(data: dataImage[indexPath.row])
        }
        
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
	
	@objc func showUserSeries() {
		self.performSegue(withIdentifier: "ShowUserSeries", sender: self)
	}
    
    @objc func showSingleSeries() {
        print("cliccato")
    }

}
