//
//  UpNextTableViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 17/05/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation
import UIKit

class UpNextTableViewController : UITableViewController {
	
	var weeks = [String]()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		weeks = ["Week 12", "Week 13", "Week 14"]
		
		tableView.register(UINib.init(nibName: "UpNextTableViewController", bundle: nil), forCellReuseIdentifier: "UpNextTableViewController")
		
		tableView.estimatedRowHeight = 50
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView,
							numberOfRowsInSection section: Int) -> Int {
		return weeks.count
	}
	
	override func tableView(_ tableView: UITableView,
							cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell =
			self.tableView.dequeueReusableCell(withIdentifier:
				"UpNextTableViewCell", for: indexPath)
				as! UpNextTableViewCell
		
		let row = indexPath.row
		cell.weekLabel.font =
			UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
		cell.weekLabel.text = weeks[row]
		return cell
	}
}
