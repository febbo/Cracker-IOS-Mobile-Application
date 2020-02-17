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
    @IBOutlet weak var issuesRead: UILabel!
    @IBOutlet weak var seriesAdded: UILabel!
    
    
//    Constants
    let userDefault = UserDefaults.standard
    
    var selectedCellIndex : Int = 0
    
    let User = Firestore.firestore().collection("Users").document("\((Auth.auth().currentUser?.uid)!)")
    
//    Variables
    var seriesIDs : [String] = []
    var seriesIMGs : [String] = []
    var totalIssues : Int = 0
    
    var dataImage : [Data] = []
    
    var reload = false
	
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
		
		seriesButton.addTarget(self, action: #selector(showUserSeries), for: UIControl.Event.touchUpInside)
        
        
        var name = Auth.auth().currentUser?.displayName
        if name == nil {
            User.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    name = data!["nickname"] as? String
                    self.nicknameOu.text = name
                } else {
                    print("nickname problem")
                }
            }
        }
        nicknameOu.text = name
        
        if name != nil {
            let imageURL = Auth.auth().currentUser?.photoURL
            imageOU.load(url: imageURL!)
        }
        
        
//        getSeries()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        seriesIDs = []
        seriesIMGs = []
        totalIssues = 0
        
        self.issuesRead.text = NSLocalizedString("Issues read: ", comment: "")
        self.seriesAdded.text = NSLocalizedString("Series added: ", comment: "")
        getSeries()
        updateStats()
    }
    
    func updateStats(){
        User.collection("Series").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var issues : Int = 0
                var series : Int = 0
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let issueRead = (data["issueToRead"] as! Int) - 1
                    series += 1
                    issues += issueRead
                }
                self.issuesRead.text! += " \(issues)"
                self.seriesAdded.text! += " \(series)"
            }
        }
    }
    
    func getSeries(){
        let overlay = BlurLoader(frame: view.frame)
        view.addSubview(overlay)
        
        User.collection("Series").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let documents = querySnapshot!.documents
                var limit = documents.count
                if limit > 6{
                    for i in 0...5 {
                        //print("\(document.documentID) => \(document.data())")
                        let data = documents[i].data()
                        let id = data["id"] as! String
                        let image = data["image"] as! String
                        self.seriesIDs.append(id)
                        self.seriesIMGs.append(image)
                        
                        
                        let url = URL(string: image)
                        self.dataImage.append( try! Data(contentsOf: url!))
                        
                    }
                }else{
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
                }
                
                overlay.removeFromSuperview()
                self.reload = true
                self.seriesCollection.reloadData()
            }
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if seriesIDs.count > 5{
            return 5
        } else{
            return seriesIDs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        
        cell.button.addTarget(self, action: #selector(showSingleSeries), for: .touchUpInside)
        cell.button.tag = indexPath.row
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
    
    @objc func showSingleSeries(button: UIButton) {
        selectedCellIndex = button.tag
        self.performSegue(withIdentifier: "fromPreviewToSerie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SeriesViewController{
            
            //print("CHE STO A PREPARA'??")
            //print(selectedCellIndex)
            //print(seriesIDs[selectedCellIndex])
            let id = seriesIDs[selectedCellIndex]
            let url = "https://gateway.marvel.com/v1/public/series/\(id)"

            destination.apiURL = url

        }
    }

}
