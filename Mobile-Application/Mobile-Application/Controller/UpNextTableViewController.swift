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
	
    @IBOutlet weak var upNextTableView : UITableView!
    
    
    
    let URL = "https://gateway.marvel.com/v1/public/comics"
    let APP_ID = "7f0eb8f2cdf6f33136bc854d89281085"
    let HASH = "1bdc741bcbdaf3d87a0f0d6e6180f877"
    let TS = "1"
    
	let cellID = "WeekCell"
	
	// array bidimensionale: ogni riga è una settimana
	// quando si usa indexPath, section per noi è la settimana, row il singolo issue
	var issues = [
		ExpandableSection(isExpanded: false, issues: []),
		ExpandableSection(isExpanded: false, issues: []),
		ExpandableSection(isExpanded: false, issues: [])
	]
	
	// come identifichiamo la settimana nell'header della sezione
	// IMPORTANTE: ovviamente la dimensione di questo array deve essere uguale al numero di righe di issues
	let weeks = ["thisWeek", "nextWeek", "thisMonth"]
	let weeksTitle = ["This week", "Next week", "This month"]
    
    var UpNextComics : [[ComicDataModel]] = [[]]
    
    
	
	var openImage = UIImage(named: "down")
	var closeImage = UIImage(named: "up")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        
        for i in 0...weeks.count-1 {
            let params : [String : String] = [ "apikey" : APP_ID, "dateDescriptor" : weeks[i], "ts": TS, "hash" : HASH]
            getUpNextData(url: URL, parameters: params, index: i)
        }
        
		
		navigationController?.navigationBar.prefersLargeTitles = true
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
		tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
//		tableView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        
        upNextTableView.dataSource = self
        upNextTableView.delegate = self
	}
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    
    
    
    
    func getUpNextData(url: String, parameters: [String: String], index: Int) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the weather data")
                let upNextJSON : JSON = JSON(response.result.value!)
                
                
//                print(upNextJSON)
                
                self.updateComicData(json : upNextJSON, index : index)
                print(self.UpNextComics)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
//                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    
    
    //Write the updateWeatherData method here:
    
    
    func updateComicData(json : JSON, index: Int) {
        
//        ciclo per i 3 tipi: thisWeek, nextWeek, nextMonth  AH NO GIA LO FACCIO SOPRA
//              prendere tutti i titoli dei comic e metterli in un array con u ciclo
//              creare l'item ExpandableSection
//              aggiungere l'item all'array issues
        
        var titles : [String] = []
        var comics : [ComicDataModel] = []
        let limit = json["data"]["limit"].intValue - 1
        
        for i in 0...limit {
            let issueTitle = json["data"]["results"][i]["title"].stringValue
//            print(title!)
            if issueTitle != ""{
                let id = json["data"]["results"][i]["id"].intValue
                let title = json["data"]["results"][i]["title"].stringValue
                let issueNumber = json["data"]["results"][i]["issueNumber"].intValue
                
                let onSaleDate = json["data"]["results"][i]["dates"][0]["date"].stringValue
                
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "dd-mm-yyyy" //Your date format
//                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
//
//                guard let date = dateFormatter.date(from: onSaleDate) else {
//                    fatalError()
//                }
                
                let serieUri = json["data"]["results"][i]["series"]["resourceURI"].stringValue
                let serieName = json["data"]["results"][i]["series"]["name"].stringValue
                let serie = SerieDataModel(URI: serieUri,  name: serieName)
                
                let imagePath = json["data"]["results"][i]["images"][0]["path"].stringValue
                let imageExt = json["data"]["results"][i]["images"][0]["extension"].stringValue
                let image = ImageIssueDataModel(path: imagePath, ext: imageExt)
                
                var creators : [CreatorDataModel] = []
                let creatorsAvailable = json["data"]["results"][i]["creators"]["available"].intValue
                for j in 0...creatorsAvailable{
                    let creatorURI = json["data"]["results"][i]["creators"]["items"][j]["resourceURI"].stringValue
                    let creatorName = json["data"]["results"][i]["creators"]["items"][j]["name"].stringValue
                    let creatorRole = json["data"]["results"][i]["creators"]["items"][j]["role"].stringValue
                    let creator = CreatorDataModel(URI: creatorURI, name: creatorName, role: creatorRole)
                
                    creators.append(creator)
                    
                }
                print(creators[0].name)
                
                let description = json["data"]["results"][i]["description"].stringValue
//                if description == "" {
//                    description = ""
//                }
                
                let comic = ComicDataModel(id: id, title: title, issueNumber: issueNumber, onSaleDate: onSaleDate, serie: serie, image: image, creators: creators, description: description)
                
                
                comics.append(comic)
                
                
                titles.append(issueTitle)
            }
        }
        
        let item = ExpandableSection(isExpanded: false, issues: titles)
        
        issues[index] = item
        if index == 0{
            UpNextComics[index] = comics
        } else {
            UpNextComics.append(comics)
        }
        
        
//        print(titles)
        
        
//        updateUIWithComicData()
    }

    
//    MARK: - Table Controls
    
    
	
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
		button.setTitle(weeksTitle[section], for: .normal)
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
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.performSegue(withIdentifier: "ShowIssue", sender: self)
	}
    
//    DINAMICIZZA LA PAGINA SINGOLA IN BASE ALLA CELLA CHE SCEGLI
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? IssueViewController{


            destination.comic = UpNextComics[(upNextTableView.indexPathForSelectedRow?.section)!][(upNextTableView.indexPathForSelectedRow?.row)!]

            print((upNextTableView.indexPathForSelectedRow?.row)!)
            print((upNextTableView.indexPathForSelectedRow?.item)!)
            print((upNextTableView.indexPathForSelectedRow?.section)!)
            print((upNextTableView.indexPathForSelectedRow?.description)!)

        }
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
