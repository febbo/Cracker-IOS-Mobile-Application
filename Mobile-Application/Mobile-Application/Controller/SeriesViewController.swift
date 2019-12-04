//
//  SeriesViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 03/10/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class SeriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - OUTLETS
    @IBOutlet weak var titleSerie: UILabel!
    @IBOutlet weak var yearsSerie: UILabel!
	@IBOutlet weak var rating: UILabel!
	@IBOutlet weak var imageSerie: UIImageView!
	@IBOutlet weak var descriptionText: UITextView!
	
	@IBOutlet weak var followButton: UIButton!
	@IBOutlet weak var readButton: UIButton!
	@IBOutlet weak var issuesTable: UITableView!
	
    //MARK: - Constants & Variables
    let User = Firestore.firestore().collection("Users").document("\((Auth.auth().currentUser?.uid)!)")
    
	var follows = false
	var allRead = false
	
	var openImage = UIImage(named: "down")
	var closeImage = UIImage(named: "up")
    
    var serieID : String = ""
    var apiURL : String?
    let APP_ID = "7f0eb8f2cdf6f33136bc854d89281085"
    let HASH = "1bdc741bcbdaf3d87a0f0d6e6180f877"
    let TS = "1"
    
    var toRead : Int = 0
    
    let cellID = "IssuesInSeriesCell"
	
	var numberOfIssues = 0
    
//    var issues = [
//        ExpandableSection(isExpanded: false, issues: [])
//    ]
    var issues : [ExpandableSection] = []
    
    let sectionsTitle : Any = []
    
    var issuesOfSerie : [Int] = []
    
    var imageSerieURL : URL?
    
    typealias FinishedDownload = () -> ()
    
	//MARK: - ViewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
        
        //        RICHIESTA API
        let singleIssueUrl = apiURL!
        let params : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH]
        getSerieData(url: singleIssueUrl, parameters: params)
		
		followButton.titleLabel?.textAlignment = .center
		readButton.titleLabel?.textAlignment = .center
        
        
		followButton.addTarget(self, action: #selector(followThisSeries), for: .touchUpInside)
		readButton.addTarget(self, action: #selector(markAllAsRead), for: .touchUpInside)
        
        readButton.backgroundColor = UIColor(named: "DarkGreen")
        readButton.setTitle("MARK ALL AS UNREAD", for: .normal)
        readButton.isEnabled = false
        readButton.alpha = 0.5
		
		issuesTable.delegate = self
		issuesTable.dataSource = self
	}
    
    
	
    //MARK: - Networking

    func getSerieData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the comic data")
                let serieJSON : JSON = JSON(response.result.value!)
                
                self.updateSerieData(json : serieJSON)
                
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
//                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    func getComicsOfSerieData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the comic data")
                let comicsJSON : JSON = JSON(response.result.value!)
                
                self.updateComicsOfSerieData(json : comicsJSON)
                
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
//                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    //MARK: - JSON Parsing
	
    func updateSerieData(json : JSON) {
        
//        ID
        let id = json["data"]["results"][0]["id"].stringValue
        print(id)
        serieID = id
        
        
        User.collection("Series").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    print("Collection got")
                    print("\(self.serieID)")
                    let docRef = self.User.collection("Series").document("\(self.serieID)")

                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
//                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                            print("Document data: \(dataDescription)")
                            print("Document exists")
                            //print(document.data()!)
                            //let data = document.data()
                            //print(data!["name"]!)
                            self.follows = true
                            self.updateBtn()
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
        }
        
//        TITLE
        var titleS = json["data"]["results"][0]["title"].stringValue
        titleS = titleS.replacingOccurrences(of: "\\(.*\\)", with: "", options: .regularExpression)
        
        titleSerie.text = titleS
        
//        YEARS
        let start = json["data"]["results"][0]["startYear"].stringValue
        let end = json["data"]["results"][0]["endYear"].stringValue
        
        if end == "2099"{
            yearsSerie.text = start + " - Present"
        } else {
            yearsSerie.text = start + " - " + end
        }
        
//      IMAGE
        let imagePath = json["data"]["results"][0]["thumbnail"]["path"].stringValue
        let imageExtension = json["data"]["results"][0]["thumbnail"]["extension"].stringValue
        
        let imageURL = URL(string: imagePath + "." + imageExtension)
        imageSerieURL = imageURL
        imageSerie.load(url: imageURL!)
        
        print(imageURL!)
        
//        DESCRIPTION
        
        let description = json["data"]["results"][0]["description"].stringValue
        if description == "" {
            descriptionText.text = "descrizione non disponibile"
        } else {
            descriptionText.text = "\(description)"
        }
        
//        RATING
        let ratingSerie = json["data"]["results"][0]["rating"].stringValue
        if ratingSerie == "" {
            rating.text = "non disponibile"
        } else {
            rating.text = "\(ratingSerie)"
        }
        
//        SECTIONS OF ISSUES

        //https://gateway.marvel.com:443/v1/public/series/23461/comics?noVariants=true&orderBy=issueNumber&limit=100&apikey=7f0eb8f2cdf6f33136bc854d89281085
        
        let comicsURL = "https://gateway.marvel.com:443/v1/public/series/\(id)/comics"
        
        let params : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH, "noVariants" : "true", "orderBy" : "issueNumber", "limit" : "100"]
        getComicsOfSerieData(url: comicsURL, parameters: params)
        
    }
    
    func updateComicsOfSerieData (json : JSON){
        var availables = json["data"]["total"].intValue - 1
		numberOfIssues = availables+1
        
        
        //Controllare se gli issues sono tutti letti
        User.collection("Series").document("\(self.serieID)").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.toRead = data!["issueToRead"] as! Int
                if self.toRead > self.numberOfIssues{
                    self.allRead = true
                    self.updateBtn()
                }
            } else {
                print("Document does not exist")
            }
        }

        
        
        //Creare le table degli issues
        issuesTable.beginUpdates()
        print(availables)
        if availables == 0 {
            var titles : [String] = []
            let comicTitle = json["data"]["results"][0]["title"].stringValue
            titles.append(comicTitle)
        }else{
            var t = 0
            var first_elem = true
            while availables > 0 {
                var titles : [String] = []
                for _ in 0...9 {
                    let comicTitle = json["data"]["results"][t]["title"].stringValue
                    if comicTitle != "" && !comicTitle.contains("Variant"){ //se in futuro volessimo mettere le celle con i comic modificare qui e modificare anche l'url
                        titles.append(comicTitle)
                        let id = json["data"]["results"][t]["id"].intValue
                        issuesOfSerie.append(id)
                    }
                    t += 1
                }
                let item = ExpandableSection(isExpanded: false, issues: titles)
                issues.append(item)
                self.issuesTable.insertSections(IndexSet(integer: issues.count - 1), with: .automatic)

                
                availables -= 10
                
            }
        }
        issuesTable.endUpdates()
        

        
        
//        print(issuesTable.cellForRow(at: [0, 0])!)
//        let cell = tableView(issuesTable, cellForRowAt: [0, 0]) as! IssuesInSeriesTableViewCell
//        print(cell.readButton!)
//        print(cell.label!.text)
//        print(cell.readButton.isSelected)
//        print(numberOfSections(in: issuesTable))
//        print(tableView(issuesTable, numberOfRowsInSection: 0))
        
    }
	
	//MARK: - Table Control
	
	//LEO
	func numberOfSections(in tableView: UITableView) -> Int {
		// Int(number of issue / 10) + 1
		return issues.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if !issues[section].isExpanded {
            return 0
        }
        return issues[section].issues.count
	}
	
	//LEO
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "IssuesInSeriesCell", for: indexPath) as? IssuesInSeriesTableViewCell
        
		let issue = issues[indexPath.section].issues[indexPath.row]
		cell?.label.text = issue
		cell?.readButton.addTarget(self, action: #selector(switchReadStatus), for: .touchUpInside)
		if #available(iOS 13.0, *) {
			cell?.backgroundColor = .systemBackground
		}
        let indexCell = (indexPath.section)*10 + indexPath.row
        if self.toRead > indexCell{
            cell?.readButton.isSelected = true
        }
//        print((indexPath.section)*10 + indexPath.row)
		return cell!
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat(55)
	}
	
	//LEO
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let button = UIButton()
		var titleString = ""
		if ((section+1)*10 < numberOfIssues) {
			titleString = "Issues " + String((section+1)*10-9) + " - " + String((section+1)*10)
		}
		else {
			titleString = "Issues " + String((section+1)*10-9) + " - " + String(numberOfIssues)
		}
		button.setTitle(titleString, for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = UIColor(named: "LightGreen")
		button.layer.cornerRadius = 15
		button.contentHorizontalAlignment = .left
		button.titleEdgeInsets.left = 15
		button.tag = section
		button.setImage(openImage, for: .normal)
		button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		button.imageView?.contentMode = .scaleAspectFit
		button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
		
		return button
	}
    
        //per andare nella pagina del singolo issue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "returnToIssue", sender: self)
    }
    
//    DINAMICIZZA LA PAGINA SINGOLA IN BASE ALLA CELLA CHE SCEGLI
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? IssueViewController{

            let index = (issuesTable.indexPathForSelectedRow?.section)! * 10 + (issuesTable.indexPathForSelectedRow?.row)!
            destination.comicID = issuesOfSerie[index]

//        print(UpNextComics[(upNextTableView.indexPathForSelectedRow?.section)!][(upNextTableView.indexPathForSelectedRow?.row)!])
//            print((upNextTableView.indexPathForSelectedRow?.row)!)
//            print((upNextTableView.indexPathForSelectedRow?.item)!)
//            print((upNextTableView.indexPathForSelectedRow?.section)!)
//            print((upNextTableView.indexPathForSelectedRow?.description)!)

        }
    }
	
	//MARK: - Actions
	
	//TODO: completare con dati profilo
    func updateBtn() {
        if (follows) {
            followButton.setTitle("UNFOLLOW THIS SERIES", for: .normal)
        }
        else {
            followButton.setTitle("FOLLOW THIS SERIES", for: .normal)
//            readButton.isEnabled = false
//            readButton.alpha = 0.5
        }
        
        if (allRead) {
            readButton.backgroundColor = UIColor(named: "DarkGreen")
            readButton.setTitle("MARK ALL AS UNREAD", for: .normal)
            readButton.isEnabled = true
            readButton.alpha = 1
        }
        else {
            readButton.backgroundColor = UIColor(named: "Red")
            readButton.setTitle("MARK ALL AS READ", for: .normal)
            readButton.isEnabled = true
            readButton.alpha = 1
        }
    }
    
    
	@objc func followThisSeries(button: UIButton) {
		follows = !follows
        let User = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
		
		if (follows) {
			followButton.setTitle("UNFOLLOW THIS SERIES", for: .normal)
            readButton.backgroundColor = UIColor(named: "Red")
            readButton.setTitle("MARK ALL AS READ", for: .normal)
			readButton.isEnabled = true
			readButton.alpha = 1
        
            User.collection("Series").document("\(serieID)").setData([
                "id": serieID,
                "name": titleSerie.text,
                "image": imageSerieURL?.absoluteString,
                "issueToRead" : 0
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
//            follows = True


		}
		else {
			followButton.setTitle("FOLLOW THIS SERIES", for: .normal)
            readButton.backgroundColor = UIColor(named: "DarkGreen")
            readButton.setTitle("MARK ALL AS UNREAD", for: .normal)
			readButton.isEnabled = false
			readButton.alpha = 0.5
            
            User.collection("Series").document("\(serieID)").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
		}
	}
	
	@objc func markAllAsRead(button: UIButton) {
		allRead = !allRead
		
		if (allRead) {
            User.collection("Series").document("\(serieID)").updateData([
                "issueToRead" : numberOfIssues + 1
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
			readButton.backgroundColor = UIColor(named: "DarkGreen")
			readButton.setTitle("MARK ALL AS UNREAD", for: .normal)
		}
		else {
            User.collection("Series").document("\(serieID)").updateData([
                "issueToRead" : 0
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
			readButton.backgroundColor = UIColor(named: "Red")
			readButton.setTitle("MARK ALL AS READ", for: .normal)
		}
	}

	//LEO
	
	@objc func handleExpandClose(button: UIButton) {
		
		let section = button.tag
		
		var indexPaths = [IndexPath]()
		for row in issues[section].issues.indices {
			let indexPath = IndexPath(row: row, section: section)
			indexPaths.append(indexPath)
		}
		let isExpanded = issues[section].isExpanded
		issues[section].isExpanded = !isExpanded
		
		button.setImage(isExpanded ? openImage : closeImage, for: .normal)
        
		
		if isExpanded {
			issuesTable.deleteRows(at: indexPaths, with: .fade)
		}
		else {
			issuesTable.insertRows(at: indexPaths, with: .fade)
            
		}
        
        print(issuesTable.indexPathsForVisibleRows)
	}
	
	@objc func switchReadStatus(button: UIButton) {
		button.isSelected = !button.isSelected
	}
    
}


class IssuesInSeriesTableViewCell : UITableViewCell {
	
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var readButton: UIButton!	
	
}
