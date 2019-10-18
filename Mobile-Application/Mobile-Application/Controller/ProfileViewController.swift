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

class ProfileViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
//    Outlets
    @IBOutlet weak var imageOU: UIImageView!
    @IBOutlet weak var nicknameOu: UILabel!

	@IBOutlet weak var seriesCollection: UICollectionView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
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
    

}
