//
//  IssueViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 08/08/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit

class IssueViewController: UIViewController {

//    @IBOutlet weak var lblIssue: UILabel!
//
//    var issueName : String?
    
	//TODO: quando avremo il profilo, utilizzeremo il valore che salviamo noi
	var isRead = false
	
	@IBOutlet weak var readButton: UIButton!
	@IBOutlet weak var seriesButton: UIButton!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.largeTitleDisplayMode = .never
        
		if (isRead) {
			readButton.backgroundColor = UIColor(named: "DarkGreen")
			readButton.setTitle("MARK AS UNREAD", for: .normal)
		}
		else {
			readButton.backgroundColor = UIColor(named: "Red")
			readButton.setTitle("MARK AS READ", for: .normal)
		}
		
		readButton.addTarget(self, action: #selector(readIssueButton), for: .touchUpInside)
		seriesButton.addTarget(self, action: #selector(goToSeriesButton), for: .touchUpInside)

//        lblIssue.text = "\((issueName)!)"
    }
	
	@objc func readIssueButton(button: UIButton) {
		isRead = !isRead
		if (isRead) {
			readButton.backgroundColor = UIColor(named: "DarkGreen")
			readButton.setTitle("MARK AS UNREAD", for: .normal)
		}
		else {
			readButton.backgroundColor = UIColor(named: "Red")
			readButton.setTitle("MARK AS READ", for: .normal)
		}
	}

	@objc func goToSeriesButton(button: UIButton) {
		self.performSegue(withIdentifier: "goToSeries", sender: self)
	}

}
