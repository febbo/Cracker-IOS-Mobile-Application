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
                "name": titleSerie.text,
                "image": imageSerieURL?.absoluteString,
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
                self.updateBtn()
            }
            if self.follows == false{
                self.follows = true
                self.updateBtn()
            }
        } else{
            print("This is the number of issue of this button selected: \(button.tag)")
            User.collection("Series").document("\(serieID)").setData([
                "id": serieID,
                "name": titleSerie.text,
                "image": imageSerieURL?.absoluteString,
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
            self.updateBtn()
        }

    }
 

}
