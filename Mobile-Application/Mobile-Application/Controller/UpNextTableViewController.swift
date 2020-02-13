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
	let weeksTitle = [NSLocalizedString("This week", comment: ""),
                      NSLocalizedString("Next week", comment: ""),
                      NSLocalizedString("This month", comment: "")]
    
    var UpNextComics : [[Int]] = [[0],[1],[2]]
    
    
	
	var openImage = UIImage(named: "down")
	var closeImage = UIImage(named: "up")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        getApiData()
        
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
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
		tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
//		tableView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)

        
        
	}

    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    
    func getApiData() {
        
        let activityIndicator = UIActivityIndicatorView(style: .gray) // Create the activity indicator
        view.addSubview(activityIndicator) // add it as a  subview
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.5) // put in the middle
        activityIndicator.startAnimating()
        
        let group = DispatchGroup()
        
        for i in 0...weeks.count-1 {
            group.enter()
            
            let params : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH, "format": "comic", "noVariants" : "true", "dateDescriptor" : weeks[i], "orderBy" : "title", "limit" : "50" ]
            
            Alamofire.request(URL, method: .get, parameters: params).responseJSON {
                response in
                if response.result.isSuccess {
                    
                    print("Success! Got the comic data")
                    let upNextJSON : JSON = JSON(response.result.value!)
                    
                    self.updateComicData(json : upNextJSON, index : i)
                    group.leave()
                    
                }
                else {
                    print("Error \(String(describing: response.result.error))")
    //                self.cityLabel.text = "Connection Issues"
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            activityIndicator.stopAnimating() // On response stop animating
            activityIndicator.removeFromSuperview() // remove the view
            // ... process data
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
        var comics : [Int] = []
        let limit = json["data"]["total"].intValue - 1
        
        
        for i in 0...limit {
            let issueTitle = json["data"]["results"][i]["title"].stringValue
//            print(title!)
            if issueTitle != ""{
                let id = json["data"]["results"][i]["id"].intValue
                
                comics.append(id)
                
                titles.append(issueTitle)
            }
            
        }
        
        let item = ExpandableSection(isExpanded: false, issues: titles)
        
        issues[index] = item

        UpNextComics[index] = comics
        
//        print(UpNextComics)
        
        
        

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


            destination.comicID = UpNextComics[(upNextTableView.indexPathForSelectedRow?.section)!][(upNextTableView.indexPathForSelectedRow?.row)!]

//        print(UpNextComics[(upNextTableView.indexPathForSelectedRow?.section)!][(upNextTableView.indexPathForSelectedRow?.row)!])
//            print((upNextTableView.indexPathForSelectedRow?.row)!)
//            print((upNextTableView.indexPathForSelectedRow?.item)!)
//            print((upNextTableView.indexPathForSelectedRow?.section)!)
//            print((upNextTableView.indexPathForSelectedRow?.description)!)

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
