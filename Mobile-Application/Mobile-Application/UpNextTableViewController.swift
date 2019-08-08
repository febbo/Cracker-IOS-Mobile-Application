//
//  UpNextTableViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 17/05/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation
import UIKit

struct cellData {
	var opened = Bool()
	var title = String()
	var sectionData = [String]()
}

class UpNextTableViewController : UITableViewController {
	
	var weeks = [String]()
	let cellSpacingHeight: CGFloat = 15
    
    var tableViewData = [cellData]()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
        tableViewData = [cellData(opened: false, title: "Title1", sectionData: ["Cell1", "Cell2", "Cell3"]),
                         cellData(opened: false, title: "Title2", sectionData: ["Cell1", "Cell2", "Cell3"]),
                         cellData(opened: false, title: "Title3", sectionData: ["Cell1", "Cell2", "Cell3"]),
                         cellData(opened: false, title: "Title4", sectionData: ["Cell1", "Cell2", "Cell3"])]
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return tableViewData.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count + 1
        } else {
            return 1
        }
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return cellSpacingHeight
	}
	
	override func tableView(_ tableView: UITableView,
							cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataIndex = indexPath.row-1
        if indexPath.row == 0{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpNextTableViewCell") else { return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].title
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
			cell.layer.cornerRadius = 10
			cell.clipsToBounds = true
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpNextTableViewCell") else { return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
			cell.layer.cornerRadius = 10
			cell.clipsToBounds = true
            return cell
        }
	}
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if tableViewData[indexPath.section].opened == true {
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        } else {
            //cosa deve accadere quando si clicca sulla singola cella
        }
    }
	
}
