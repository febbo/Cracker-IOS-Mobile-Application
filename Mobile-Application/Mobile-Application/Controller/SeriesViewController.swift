//
//  SeriesViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 03/10/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SeriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleSerie: UILabel!
    @IBOutlet weak var yearsSerie: UILabel!
	@IBOutlet weak var rating: UILabel!
	@IBOutlet weak var imageSerie: UIImageView!
	@IBOutlet weak var descriptionText: UITextView!
	
	@IBOutlet weak var followButton: UIButton!
	@IBOutlet weak var readButton: UIButton!
	@IBOutlet weak var issuesTable: UITableView!
	
	var follows = false
	var allRead = false
	
	var openImage = UIImage(named: "down")
	var closeImage = UIImage(named: "up")
    
    var serieID : Int?
    var apiURL : String?
    let APP_ID = "7f0eb8f2cdf6f33136bc854d89281085"
    let HASH = "1bdc741bcbdaf3d87a0f0d6e6180f877"
    let TS = "1"
    
    let cellID = "IssueCell"
    
    var issues = [
        ExpandableSection(isExpanded: false, issues: []),
        ExpandableSection(isExpanded: false, issues: [])
    ]
    
    let sectionsTitle : Any = []
    
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        //        RICHIESTA API
        let singleIssueUrl = apiURL!
        let params : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH]
        getUpNextData(url: singleIssueUrl, parameters: params)
		
		followButton.titleLabel?.textAlignment = .center
		readButton.titleLabel?.textAlignment = .center
		
		if (follows) {
			followButton.setTitle("UNFOLLOW THIS SERIES", for: .normal)
		}
		else {
			followButton.setTitle("FOLLOW THIS SERIES", for: .normal)
			readButton.isEnabled = false
			readButton.alpha = 0.5
		}
		
		if (allRead) {
			readButton.backgroundColor = UIColor(named: "DarkGreen")
			readButton.setTitle("MARK ALL AS UNREAD", for: .normal)
		}
		else {
			readButton.backgroundColor = UIColor(named: "Red")
			readButton.setTitle("MARK ALL AS READ", for: .normal)
		}
		
		followButton.addTarget(self, action: #selector(followThisSeries), for: .touchUpInside)
		readButton.addTarget(self, action: #selector(markAllAsRead), for: .touchUpInside)
		
		issuesTable.delegate = self
		issuesTable.dataSource = self
	}
	
    //MARK: - Networking

    func getUpNextData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the comic data")
                let upNextJSON : JSON = JSON(response.result.value!)
                
                self.updateComicData(json : upNextJSON)
                
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
//                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    //MARK: - JSON Parsing
	
    func updateComicData(json : JSON) {
        
//        ID
        let id = json["data"]["results"][0]["id"].stringValue
        print(id)
        
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
        imageSerie.load(url: imageURL!)
        
        print(imageURL!)
        
//        DESCRIPTION
        
        let description = json["data"]["results"][0]["description"].stringValue
//        descriptionComic.text = "\((comic?.description)!)"
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
        var titles : [String] = []
        let availables = json["data"]["results"][0]["comics"]["available"].intValue - 1
        
        print(availables)
        if availables == 0 {
            let comicTitle = json["data"]["results"][0]["comics"]["items"][0]["name"].stringValue
            titles.append(comicTitle)
        }else{
            for i in 0...availables {
                let comicTitle = json["data"]["results"][0]["comics"]["items"][i]["name"].stringValue
    //            print(title!)
                if comicTitle != ""{
                    titles.append(comicTitle)
                }
            }
        }
        
        let item = ExpandableSection(isExpanded: false, issues: titles)
        
//        issues[index] = item
        
        issues[0] = item
        
        
        
        
        
        
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "IssueCell", for: indexPath)
        
        let issue = issues[indexPath.section].issues[indexPath.row]
        cell.textLabel?.text = issue
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat(55)
	}
	
	//LEO
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let button = UIButton()
		button.setTitle("Da sistemare", for: .normal)
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
	
	//MARK: - Actions
	
	//TODO: completare con dati profilo
	
	@objc func followThisSeries(button: UIButton) {
		follows = !follows
		
		if (follows) {
			followButton.setTitle("UNFOLLOW THIS SERIES", for: .normal)
			readButton.isEnabled = true
			readButton.alpha = 1
		}
		else {
			followButton.setTitle("FOLLOW THIS SERIES", for: .normal)
			readButton.isEnabled = false
			readButton.alpha = 0.5
		}
	}
	
	@objc func markAllAsRead(button: UIButton) {
		allRead = !allRead
		
		if (allRead) {
			readButton.backgroundColor = UIColor(named: "DarkGreen")
			readButton.setTitle("MARK ALL AS UNREAD", for: .normal)
		}
		else {
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
	}

}
