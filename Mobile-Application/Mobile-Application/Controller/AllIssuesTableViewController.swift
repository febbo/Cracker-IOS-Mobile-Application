//
//  AllIssuesTableViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 15/02/2020.
//  Copyright © 2020 Leonardo Febbo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class AllIssuesTableViewController: UITableViewController {

    @IBOutlet var issuesTable: UITableView!
    
    var serieID : String = ""
    var titleSerie : String = ""
    var imageSerieURL : String = ""
    let APP_ID = "7f0eb8f2cdf6f33136bc854d89281085"
    let HASH = "1bdc741bcbdaf3d87a0f0d6e6180f877"
    let TS = "1"
    
    let User = Firestore.firestore().collection("Users").document("\((Auth.auth().currentUser?.uid)!)")
    
    var allRead = false
    
    let cellID = "IssuesInSeriesCell"
    var openImage = UIImage(named: "down")
    var closeImage = UIImage(named: "up")
    
    var issues : [ExpandableSection] = []
    let sectionsTitle : Any = []
    var issuesOfSerie : [Int] = []
    var toRead : Int = 0
    var numberOfIssues = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getIssuesOfSerie()
    }
    
    // MARK: - Firebase and API
    
    func getIssuesOfSerie() {
        let comicsURL = "https://gateway.marvel.com:443/v1/public/series/\(serieID)/comics"
        
        let params : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH, "noVariants" : "true", "orderBy" : "issueNumber", "limit" : "100"]
        
        Alamofire.request(comicsURL, method: .get, parameters: params).responseJSON {
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
                }
            } else {
                print("Document does not exist")
            }
        }

        
        
        //Creare le table degli issues

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

        
    }
    

    // MARK: - Table view data source

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
            let cell = tableView.dequeueReusableCell(withIdentifier: "IssuesInSeriesCell", for: indexPath) as? IssuesInSeriesTableViewCell
            print(issues)
            let issue = issues[indexPath.section].issues[indexPath.row]
            cell?.label.text = issue
            cell?.readButton.addTarget(self, action: #selector(switchReadStatus), for: .touchUpInside)
            cell?.readButton.tag = indexPath.section*10 + (indexPath.row + 1)
            if #available(iOS 13.0, *) {
                cell?.backgroundColor = .systemBackground
            }
            let indexCell = (indexPath.section)*10 + (indexPath.row + 1)
            if self.toRead > indexCell{
                cell?.readButton.isSelected = true
            } else {
                cell?.readButton.isSelected = false
            }
    //        print((indexPath.section)*10 + indexPath.row)
            return cell!
        }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(55)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let button = UIButton()
        var titleString = ""
        if ((section+1)*10 < numberOfIssues) {
            titleString = NSLocalizedString("Issues", comment: "") + " " + String((section+1)*10-9) + " - " + String((section+1)*10)
        }
        else {
            titleString = NSLocalizedString("Issues", comment: "") + " " + String((section+1)*10-9) + " - " + String(numberOfIssues)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "returnToIssue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? IssueViewController{

            let index = (issuesTable.indexPathForSelectedRow?.section)! * 10 + (issuesTable.indexPathForSelectedRow?.row)!
            destination.comicID = issuesOfSerie[index]
        }
    }
    
    // MARK: - Actions

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
        if button.isSelected == false {
            print("This is the number of issue of this button selected: \(button.tag)")
            User.collection("Series").document("\(serieID)").setData([
                "id": serieID,
                "name": titleSerie,
                "image": imageSerieURL,
                "issueToRead" : button.tag + 1
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            self.toRead = button.tag + 1
            button.isSelected = !button.isSelected
            self.issuesTable.reloadData()
            if self.toRead > self.numberOfIssues {
                self.allRead = true
            }
        } else{
            print("This is the number of issue of this button selected: \(button.tag)")
            User.collection("Series").document("\(serieID)").setData([
                "id": serieID,
                "name": titleSerie,
                "image": imageSerieURL,
                "issueToRead" : button.tag
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            self.toRead = button.tag
            button.isSelected = !button.isSelected
            self.issuesTable.reloadData()
            self.allRead = false
        }

    }
 

}

class IssuesInSeriesTableViewCell : UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var readButton: UIButton!
    
}
