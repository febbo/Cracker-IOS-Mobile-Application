//
//  IssueViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 08/08/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class IssueViewController: UIViewController {

    @IBOutlet weak var titleComic: UILabel!
    @IBOutlet weak var dateComic: UILabel!
    @IBOutlet weak var creatorsComic1: UILabel!
    @IBOutlet weak var descriptionComic: UITextView!
    @IBOutlet weak var imageComic: UIImageView!
    
    var comicID : Int?
    
	//TODO: quando avremo il profilo, utilizzeremo il valore che salviamo noi
	var isRead = false
	
	@IBOutlet weak var readButton: UIButton!
	@IBOutlet weak var seriesButton: UIButton!
    
    let apiURL = "https://gateway.marvel.com:443/v1/public/comics/"
    let APP_ID = "7f0eb8f2cdf6f33136bc854d89281085"
    let HASH = "1bdc741bcbdaf3d87a0f0d6e6180f877"
    let TS = "1"
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.largeTitleDisplayMode = .never
        
//        RICHIESTA API
        let singleIssueUrl = apiURL + "\(String(describing: comicID))"
        let params : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH]
        getUpNextData(url: singleIssueUrl, parameters: params)
        
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
    
    func getUpNextData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the comic data")
                let upNextJSON : JSON = JSON(response.result.value!)
                
                self.updateComicData(json : upNextJSON)
                
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
//                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    func updateComicData(json : JSON) {
        titleComic.text = json["data"]["results"][0]["title"].stringValue
        dateComic.text = json["data"]["results"][0]["dates"][0]["date"].stringValue
        let nameCreator1 = json["data"]["results"][0]["creators"]["items"][0]["name"].stringValue
        let roleCreator1 = json["data"]["results"][0]["creators"]["items"][0]["role"].stringValue
        if nameCreator1 == "" || roleCreator1 == ""{
            creatorsComic1.text = "autori non disponibili"
        } else {
            creatorsComic1.text = "\(nameCreator1) : \(roleCreator1)"
        }
        
        let description = json["data"]["results"][0]["description"].stringValue
//        descriptionComic.text = "\((comic?.description)!)"
        if description == "" {
            descriptionComic.text = "descrizione non disponibile"
        } else {
            descriptionComic.text = "\(description)"
        }
        
        let imagePath = json["data"]["results"][0]["images"][0]["path"].stringValue
        let imageExtension = json["data"]["results"][0]["images"][0]["extension"].stringValue
        
        let imageURL = URL(string: imagePath + "." + imageExtension)
        imageComic.load(url: imageURL!)
        print(imageURL!)
        
        
    }
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
