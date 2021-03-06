//
//  ToReadCollectionViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 04/12/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class ToReadCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
//    Alamofire API

    let APP_ID = "7f0eb8f2cdf6f33136bc854d89281085"
    let HASH = "1bdc741bcbdaf3d87a0f0d6e6180f877"
    let TS = "1"
    
//    Firebase User
    let User = Firestore.firestore().collection("Users").document("\((Auth.auth().currentUser?.uid)!)")
    
    var cellSize: CGSize?
    var imageSize: CGSize?
    
    var seriesIDs : [String] = []
    var issuesToRead : [Int] = []
    
    var serieNotCompletedIDs : [String] = []
    var issuesToReadReal : [Int] = []
    var issuesIMGs : [Data] = []
    var issuesIDs : [String] = []
    

    var selectedCellIndex : Int = 0
    
    var reload = false
    
    let aspectRatio: CGFloat = 251/162

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getDataFromFirebase()
        
        let collectionViewSize = collectionView.frame.size.width - 60
        if (traitCollection.horizontalSizeClass == .regular) {
            cellSize = CGSize(width: collectionViewSize/3, height: collectionViewSize/3 * aspectRatio)
            imageSize = CGSize(width: collectionViewSize/3 - 15, height: (collectionViewSize/3 - 15) * aspectRatio)
        }
        else {
            cellSize = CGSize(width: collectionViewSize/2, height: collectionViewSize/2 * aspectRatio)
            imageSize = CGSize(width: collectionViewSize/2, height: collectionViewSize/2 * aspectRatio)
        }

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "DarkGreen")

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationItem.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        getDataFromFirebase()
    }
    
    
    func firebase(completion: @escaping () -> Void){
        User.collection("Series").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var tempID : [String] = []
                var tempToRead : [Int] = []
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let id = data["id"] as! String
                    let toRead = data["issueToRead"] as! Int
                    
                    tempID.append(id)
                    tempToRead.append(toRead)

                    
//                    let url = URL(string: image)
//                    self.dataImage.append( try! Data(contentsOf: url!))
                }
                self.seriesIDs = tempID
                self.issuesToRead = tempToRead

                completion()
//                print(self.seriesIDs)
//                print(self.seriesIMGs)
//                self.reload = true
//                self.collectionView.reloadData()
            }
        }
    }
    
    func getDataFromFirebase(){
//        let activityIndicator = UIActivityIndicatorView(style: .gray) // Create the activity indicator
//        view.addSubview(activityIndicator) // add it as a  subview
//        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.5) // put in the middle
//        activityIndicator.color = UIColor(named: "LoadingIndicator")
//        activityIndicator.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
//        activityIndicator.startAnimating()
        
        let overlay = BlurLoader(frame: view.frame)
        view.addSubview(overlay)
        
        firebase(completion: {
            let group = DispatchGroup()
            var tempToReadReal = [Int](repeating: -1, count: 50)
            var tempNotCompleted = [String](repeating: "", count: 50)
            var tempID = [String](repeating: "", count: 50)
            var tempIMG = [Data](repeating: Data(), count: 50)
            for i in 0...self.seriesIDs.count-1 {
                
                group.enter()
                let url = "https://gateway.marvel.com/v1/public/series/\(self.seriesIDs[i])/comics"
                let params : [String : String] = [ "apikey" : self.APP_ID, "ts": self.TS, "hash" : self.HASH, "noVariants" : "true", "limit" : "1" , "issueNumber": "\(self.issuesToRead[i])"]
                        
                Alamofire.request(url, method: .get, parameters: params).responseJSON {
                    response in
                    if response.result.isSuccess {
                        
                        let json : JSON = JSON(response.result.value!)
                        
                        if json["data"]["count"] == 1 {
                            
//                            tempToReadReal.append(self.issuesToRead[i])
                            tempToReadReal.insert(self.issuesToRead[i], at: i)
//                            tempNotCompleted.append(self.seriesIDs[i])
                            tempNotCompleted.insert(self.seriesIDs[i], at: i)
//                            self.issuesToReadReal.append(self.issuesToRead[i])
//                            self.serieNotCompletedIDs.append(self.seriesIDs[i])
                            
                            
                            print("Success! Got the comic data")
                            let id = json["data"]["results"][0]["id"].stringValue
//                            tempID.append(id)
                            tempID.insert(id, at: i)
//                            self.issuesIDs.append(id)
                            
                            let imagePath = json["data"]["results"][0]["thumbnail"]["path"].stringValue
                            let imageExtension = json["data"]["results"][0]["thumbnail"]["extension"].stringValue
                            
                            let imageURL = URL(string: imagePath + "." + imageExtension)
//                            tempIMG.append(try! Data(contentsOf: imageURL!))
                            tempIMG.insert(try! Data(contentsOf: imageURL!), at: i)
//                            self.issuesIMGs.append(try! Data(contentsOf: imageURL!))
                        }
                        else if json["data"]["count"] == 0{
                            print("All issues read of serie \(self.seriesIDs[i])")
                        }
                        else{
                            print("Something Wrong")
                        }
                        group.leave()
        //                self.collectionView.reloadData()
                        
                    }
                    else {
                        print("Error \(String(describing: response.result.error))")
        //                self.cityLabel.text = "Connection Issues"
                    }

                }
            }
            group.notify(queue: DispatchQueue.main) {
                tempToReadReal = tempToReadReal.filter({ $0 != -1})
                tempNotCompleted = tempNotCompleted.filter({ $0 != ""})
                tempID = tempID.filter({ $0 != ""})
                tempIMG = tempIMG.filter({ $0 != Data()})
                
                self.issuesToReadReal = tempToReadReal
                self.serieNotCompletedIDs = tempNotCompleted
                self.issuesIDs = tempID
                self.issuesIMGs = tempIMG
                
//                activityIndicator.stopAnimating() // On response stop animating
//                activityIndicator.removeFromSuperview() // remove the view

                overlay.removeFromSuperview()
                
                self.reload = true
                self.collectionView.reloadData()
                
            }

        })

        

    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return issuesIMGs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToReadCell", for: indexPath) as! ToReadCollectionViewCell
        var img = UIImage(named: "issue")!.resized(to: imageSize!)
        
        cell.tag = indexPath.row
        
        if self.reload == true{
//            let url = URL(string: seriesIMGs[indexPath.row])
//            let imageData = try! Data(contentsOf: url!)
            img = UIImage(data: issuesIMGs[indexPath.row])!.resized(to: imageSize!)
        }
        
        cell.issueImage.setBackgroundImage(img, for: UIControl.State.normal)
        cell.issueImage.addTarget(self, action: #selector(showIssue), for: UIControl.Event.touchUpInside)
        cell.issueImage.tag = indexPath.row
        cell.readButton.addTarget(self, action: #selector(markAsRead), for: UIControl.Event.touchUpInside)
        cell.readButton.tag = indexPath.row
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return cellSize!
    }
    
    //TODO
    @objc func markAsRead(button: UIButton) {
        // se è l'ultimo issue disponibile della serie, far scomparire la cella;
        // altrimenti, caricare l'issue successivo nella serie
//        let issueSelected = issuesIDs[button.tag]
        
        issuesToReadReal[button.tag] = issuesToReadReal[button.tag] + 1
        
        User.collection("Series").document("\(serieNotCompletedIDs[button.tag])").updateData([
            "issueToRead" : issuesToReadReal[button.tag]
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let url = "https://gateway.marvel.com/v1/public/series/\(serieNotCompletedIDs[button.tag])/comics"
        let params : [String : String] = [ "apikey" : self.APP_ID, "ts": self.TS, "hash" : self.HASH, "noVariants" : "true", "limit" : "1" , "issueNumber": "\(issuesToReadReal[button.tag])"]
        
        var finished : Bool = false
        let group = DispatchGroup()
        group.enter()
        Alamofire.request(url, method: .get, parameters: params).responseJSON {
            response in
            if response.result.isSuccess {
                
                let json : JSON = JSON(response.result.value!)
                
                if json["data"]["count"] == 1 {
                    
                    
                    print("Success! Got the comic data")
                    
                    let imagePath = json["data"]["results"][0]["thumbnail"]["path"].stringValue
                    let imageExtension = json["data"]["results"][0]["thumbnail"]["extension"].stringValue
                    
                    let imageURL = URL(string: imagePath + "." + imageExtension)
                    self.issuesIMGs[button.tag] = try! Data(contentsOf: imageURL!)
                    
                    let id = json["data"]["results"][0]["id"].stringValue
                    self.issuesIDs[button.tag] = id
                }
                else if json["data"]["count"] == 0{
                    print("All issues read of serie \(self.serieNotCompletedIDs[button.tag])")
                    finished = true
                    self.serieNotCompletedIDs.remove(at: button.tag)
                    self.issuesToReadReal.remove(at: button.tag)
                    self.issuesIMGs.remove(at: button.tag)
                    self.issuesIDs.remove(at: button.tag)

                }
                else{
                    print("Something Wrong")
                }
                group.leave()
            }
            else {
                print("Error \(String(describing: response.result.error))")
                group.leave()
            }

        }

        
        group.notify(queue: DispatchQueue.main) {
            
            if finished == false{
                let alert = UIAlertController(title: NSLocalizedString("Issue read", comment: ""), message: NSLocalizedString("Congratulations! Let's go!", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Great!", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("You're up to date", comment: ""), message: NSLocalizedString("You have read all issues of this serie!\n Congratulations!", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Great!", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true)
            }

            
            
            
            self.reload = true
            self.collectionView.reloadData()
        }
        
        
    }
    
    @objc func showIssue(button: UIButton) {
        selectedCellIndex = button.tag
        self.performSegue(withIdentifier: "ShowIssueFromToRead", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? IssueViewController{
            
            let id = issuesIDs[selectedCellIndex]
            
            destination.comicID = Int(id)

        }
    }

}


class ToReadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var issueImage: UIButton!
    @IBOutlet weak var readButton: UIButton!
    
}
