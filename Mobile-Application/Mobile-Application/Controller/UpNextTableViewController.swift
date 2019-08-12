//
//  UpNextTableViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 17/05/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class UpNextTableViewController : UITableViewController {
	
    let URL = "http(s)://gateway.marvel.com:443/v1/public/comics"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    
	let cellID = "WeekCell"
	
	// array bidimensionale: ogni riga è una settimana
	// quando si usa indexPath, section per noi è la settimana, row il singolo issue
	var issues = [
		ExpandableSection(isExpanded: false, issues: ["Captain Marvel 9", "Fantastic Four 13", "Powers of X 2"]),
		ExpandableSection(isExpanded: false, issues: ["Fearless 2", "Powers of X 3"]),
		ExpandableSection(isExpanded: false, issues: ["House of X 3", "Runaways 24", "Venom 17"])
	]
	
	// come identifichiamo la settimana nell'header della sezione
	// IMPORTANTE: ovviamente la dimensione di questo array deve essere uguale al numero di righe di issues
	let weeks = ["thisWeek", "nextWeek", "thisMonth"]
    
    
	
	var openImage = UIImage(named: "down")
	var closeImage = UIImage(named: "up")
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
//        for i in weeks {
//            let params : [String : String] = ["dateDescriptor" : i, "apikey" : APP_ID]
//            getUpNextData(url: URL, parameters: params)
//        }
        
        
		navigationController?.navigationBar.prefersLargeTitles = true
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
		tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
	}
    
    
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    
    
    
    
    func getUpNextData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the weather data")
                let upNextJSON : JSON = JSON(response.result.value!)
                
                
                print(upNextJSON)
                
//                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
//                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return issues.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if !issues[section].isExpanded {
			return 0
		}
		return issues[section].issues.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "WeekCell", for: indexPath)
		let issue = issues[indexPath.section].issues[indexPath.row]
		cell.textLabel?.text = issue
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat(55)
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let button = UIButton()
		button.setTitle(weeks[section], for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = UIColor(named: "AccentColor")
//		button.layer.cornerRadius = 10
		button.contentHorizontalAlignment = .left
		button.titleEdgeInsets.left = 15
		button.tag = section
		button.setImage(openImage, for: .normal)
		button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		button.imageView?.contentMode = .scaleAspectFit
		button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
		
		return button

	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.performSegue(withIdentifier: "ShowIssue", sender: self)
	}
	
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
			tableView.deleteRows(at: indexPaths, with: .fade)
		}
		else {
			tableView.insertRows(at: indexPaths, with: .fade)
		}
	}
	
}