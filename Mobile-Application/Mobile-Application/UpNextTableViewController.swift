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
	
	let cellID = "WeekCell"
	
	// array bidimensionale: ogni riga è una settimana
	// quando si usa indexPath, section per noi è la settimana, row il singolo issue
	let issues = [
		["Captain Marvel 9", "Fantastic Four 13", "Powers of X 2"],
		["Fearless 2", "Powers of X 3"],
		["House of X 3", "Runaways 24", "Venom 17"]
	]
	
	// come identifichiamo la settimana nell'header della sezione
	// IMPORTANTE: ovviamente la dimensione di questo array deve essere uguale al numero di righe di issues
	let weeks = ["Week 45", "Week 46", "Week 47"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return issues.count
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		label.text = weeks[section]
		label.backgroundColor = .orange
		return label
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return issues[section].count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "WeekCell", for: indexPath)
		let issue = issues[indexPath.section][indexPath.row]
		cell.textLabel?.text = issue
		
		return cell
	}
	
//	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		let button = UIButton(type: .system)
//		button.setTitle("Close", for: .normal)
//		button.setTitleColor(.black, for: .normal)
//		button.backgroundColor = .orange
//		return button
//	}
	
}
