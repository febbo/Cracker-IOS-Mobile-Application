//
//  UserSeriesCollectionViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 18/11/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class UserSeriesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let User = Firestore.firestore().collection("Users").document("\((Auth.auth().currentUser?.uid)!)")
	
	var cellSize: CGSize?
    var imageSize: CGSize?
    
    var seriesIDs : [String] = []
    var seriesIMGs : [String] = []
    
    var dataImage : [Data] = []
    
    var reload = false
    
    var selectedCellIndex : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        getSeries()

		
		let collectionViewSize = collectionView.frame.size.width - 60
		if (traitCollection.horizontalSizeClass == .regular) {
			cellSize = CGSize(width: collectionViewSize/3, height: collectionViewSize/3)
            imageSize = CGSize(width: collectionViewSize/3 - 15, height: collectionViewSize/3 - 15)
		}
		else {
			cellSize = CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
            imageSize = CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
		}
    }
    
    
    func getSeries(){
        let activityIndicator = UIActivityIndicatorView(style: .gray) // Create the activity indicator
        view.addSubview(activityIndicator) // add it as a  subview
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.5) // put in the middle
        activityIndicator.startAnimating()
        
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
                print(self.seriesIDs)
                print(self.seriesIMGs)
                activityIndicator.stopAnimating() // On response stop animating
                activityIndicator.removeFromSuperview() // remove the view
                
                self.reload = true
                self.collectionView.reloadData()
            }
        }

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return seriesIDs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserSeriesCell", for: indexPath) as! UserSeriesCollectionViewCell
        cell.tag = indexPath.row

        var img = UIImage(named: "series")!.resized(to: imageSize!)
        if self.reload == true{
//            let url = URL(string: seriesIMGs[indexPath.row])
//            let imageData = try! Data(contentsOf: url!)
            img = UIImage(data: dataImage[indexPath.row])!.resized(to: imageSize!)
        }
        cell.seriesImage.setBackgroundImage(img, for: UIControl.State.normal)
        cell.seriesImage.addTarget(self, action: #selector(showSeries), for: UIControl.Event.touchUpInside)
        cell.seriesImage.tag = indexPath.row //QUESTO é IL TAG DEL BOTTONE
    
        return cell
    }
    

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
		return cellSize!
    }
    
    @objc func showSeries(button: UIButton) {
        //print("sono entrato")
        selectedCellIndex = button.tag
        //print(selectedCellIndex)
        self.performSegue(withIdentifier: "ShowSeriesFromProfile", sender: self)

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


public extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
