//
//  IssueViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 08/08/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit

class IssueViewController: UIViewController {

    @IBOutlet weak var titleComic: UILabel!
    @IBOutlet weak var dateComic: UILabel!
    @IBOutlet weak var creatorsComic: UILabel!
    @IBOutlet weak var descriptionComic: UITextView!
    
    var comic : ComicDataModel?
    
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

        titleComic.text = "\((comic?.title)!)"
        dateComic.text = "\((comic?.onSaleDate)!)"
        if comic?.creators[0].name == nil || comic?.creators[0].role == nil{
            creatorsComic.text = "autori non disponibili"
        } else {
            creatorsComic.text = "\((comic?.creators[0].name)!)  \((comic?.creators[0].role)!)"
        }
        

//        descriptionComic.text = "\((comic?.description)!)"
        if comic?.description == "" {
            descriptionComic.text = "descrizione non disponibile"
        } else {
            descriptionComic.text = "\((comic?.description)!)"
        }
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
