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

class SeriesViewController: UIViewController {
    
    @IBOutlet weak var titleSerie: UILabel!
    @IBOutlet weak var yearsSerie: UILabel!
	@IBOutlet weak var rating: UILabel!
	@IBOutlet weak var imageSerie: UIImageView!
	@IBOutlet weak var descriptionText: UITextView!
	
	@IBOutlet weak var followButton: UIButton!
	@IBOutlet weak var readButton: UIButton!
	
	var follows = false
	var allRead = false
    
    
    var serieID : Int?
    var apiURL : String?
    let APP_ID = "7f0eb8f2cdf6f33136bc854d89281085"
    let HASH = "1bdc741bcbdaf3d87a0f0d6e6180f877"
    let TS = "1"
    
	
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
        
        let id = json["data"]["results"][0]["id"].stringValue
        print(id)
        
        var titleS = json["data"]["results"][0]["title"].stringValue
        titleS = titleS.replacingOccurrences(of: "\\(.*\\)", with: "", options: .regularExpression)
        
        titleSerie.text = titleS
        
        let start = json["data"]["results"][0]["startYear"].stringValue
        let end = json["data"]["results"][0]["endYear"].stringValue
        
        if end == "2099"{
            yearsSerie.text = start + " - Present"
        } else {
            yearsSerie.text = start + " - " + end
        }

        let imagePath = json["data"]["results"][0]["thumbnail"]["path"].stringValue
        let imageExtension = json["data"]["results"][0]["thumbnail"]["extension"].stringValue
        
        let imageURL = URL(string: imagePath + "." + imageExtension)
        imageSerie.load(url: imageURL!)
        
        print(imageURL!)
        
        
        
        
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
}
