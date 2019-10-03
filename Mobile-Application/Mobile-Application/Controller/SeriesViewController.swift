//
//  SeriesViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 03/10/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit

class SeriesViewController: UIViewController {
	
	@IBOutlet weak var followButton: UIButton!
	@IBOutlet weak var readButton: UIButton!
	
	var follows = false
	var allRead = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
