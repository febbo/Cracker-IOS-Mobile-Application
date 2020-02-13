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
import Firebase

class IssueViewController: UIViewController {

    @IBOutlet weak var titleComic: UILabel!
    @IBOutlet weak var dateComic: UILabel!
	@IBOutlet weak var descriptionComic: UITextView!
    @IBOutlet weak var imageComic: UIImageView!
    @IBOutlet weak var creatorsText: UITextView!
    
    let User = Firestore.firestore().collection("Users").document("\((Auth.auth().currentUser?.uid)!)")
    var parsedIdSerie : String = ""
    var nameOfSerie : String = ""
    var issueNumber : Int = 0
    var imageSerie : String = ""

    let group = DispatchGroup()
    
    var comicID : Int?
    
	//TODO: quando avremo il profilo, utilizzeremo il valore che salviamo noi
	var isRead = false
	
	@IBOutlet weak var readButton: UIButton!
	@IBOutlet weak var seriesButton: UIButton!
    
    let apiURL = "https://gateway.marvel.com/v1/public/comics/"
    let APP_ID = "7f0eb8f2cdf6f33136bc854d89281085"
    let HASH = "1bdc741bcbdaf3d87a0f0d6e6180f877"
    let TS = "1"
    
    var serieURL: String?
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var scrollHeight: CGFloat = 0
    var scrollWidth: CGFloat = 0
    
	override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.largeTitleDisplayMode = .never
        
        scrollWidth = scrollView.contentSize.width
        scrollHeight = 20*6 + 50*4
        scrollHeight += headerView.frame.height
        scrollHeight += creatorsText.frame.height
        scrollHeight += descriptionComic.frame.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        
//        RICHIESTA API
        let singleIssueUrl = apiURL + "\(comicID ?? 0)"
        let params : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH]
        getUpNextData(url: singleIssueUrl, parameters: params)

        
		if (isRead) {
			readButton.backgroundColor = UIColor(named: "DarkGreen")
			readButton.setTitle(NSLocalizedString("MARK AS UNREAD", comment: ""), for: .normal)
		}
		else {
			readButton.backgroundColor = UIColor(named: "Red")
			readButton.setTitle(NSLocalizedString("MARK AS READ", comment: ""), for: .normal)
		}
		
		readButton.addTarget(self, action: #selector(readIssueButton), for: .touchUpInside)
		seriesButton.addTarget(self, action: #selector(goToSeriesButton), for: .touchUpInside)


    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
                
        //        RICHIESTA API
        let singleIssueUrl = apiURL + "\(comicID ?? 0)"
        let params : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH]
        getUpNextData(url: singleIssueUrl, parameters: params)
        
        if (isRead) {
            readButton.backgroundColor = UIColor(named: "DarkGreen")
            readButton.setTitle(NSLocalizedString("MARK AS UNREAD", comment: ""), for: .normal)
        }
        else {
            readButton.backgroundColor = UIColor(named: "Red")
            readButton.setTitle(NSLocalizedString("MARK AS READ", comment: ""), for: .normal)
        }
        
        readButton.addTarget(self, action: #selector(readIssueButton), for: .touchUpInside)
        seriesButton.addTarget(self, action: #selector(goToSeriesButton), for: .touchUpInside)


    }
    
    override func viewDidLayoutSubviews() {
        scrollHeight = 20*6 + 50*4
        scrollHeight += headerView.frame.height
        scrollHeight += creatorsText.frame.height
        scrollHeight += descriptionComic.frame.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
    }
    
    //MARK: - Networking
    
    func getUpNextData(url: String, parameters: [String: String]) {
        
        let overlay = BlurLoader(frame: view.frame)
        view.addSubview(overlay)
        
        
        group.enter()
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the comic data")
                let upNextJSON : JSON = JSON(response.result.value!)
                
                self.updateComicData(json : upNextJSON)
                self.group.leave()
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
//                self.cityLabel.text = "Connection Issues"
            }
        }
        group.notify(queue: DispatchQueue.main) {
            
            overlay.removeFromSuperview()
            
        }
        
    }
    
    func getSerieData(url: String, parameters: [String: String]) {
        group.enter()
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the comic data")
                let upNextJSON : JSON = JSON(response.result.value!)
                
                self.updateSerieData(json : upNextJSON)
                self.group.leave()
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
//                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    //MARK: - JSON Parsing
    
    func updateSerieData(json : JSON) {
        //      IMAGE
        let imagePath = json["data"]["results"][0]["thumbnail"]["path"].stringValue
        let imageExtension = json["data"]["results"][0]["thumbnail"]["extension"].stringValue
        imageSerie = imagePath + "." + imageExtension
    }
    
    func updateComicData(json : JSON) {
//        print(json)
//        let status = json["status"]
//        print(status)
        group.enter()
        titleComic.text = json["data"]["results"][0]["title"].stringValue

        
        let dateString = json["data"]["results"][0]["dates"][0]["date"].stringValue
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy"

        if let date = dateFormatterGet.date(from: "\(dateString)") {
            dateComic.text = NSLocalizedString("Release date", comment: "") + dateFormatterPrint.string(from: date)
        } else {
           print("There was an error decoding the string")
            dateComic.text = "error"
        }
        
        let numberCreators = json["data"]["results"][0]["creators"]["returned"].intValue
        
        var text : String = ""
        if numberCreators != 0{
            for i in 0...(numberCreators - 1) {
                let name = json["data"]["results"][0]["creators"]["items"][i]["name"].stringValue
                let role = json["data"]["results"][0]["creators"]["items"][i]["role"].stringValue
                if i == (numberCreators-1) {
                    text += " \(name): \(role) "
                }else {
                    text += " \(name): \(role) \n"
                }
            }
        }else{
            text = NSLocalizedString("No creator found", comment: "")
        }
        
        creatorsText.text = text
        
        
        let description = json["data"]["results"][0]["description"].stringValue
//        descriptionComic.text = "\((comic?.description)!)"
        if description == "" {
            descriptionComic.text = NSLocalizedString("Solicit not available", comment: "")
        } else {
            descriptionComic.text = "\(description)"
        }
        
        let imagePath = json["data"]["results"][0]["images"][0]["path"].stringValue
        let imageExtension = json["data"]["results"][0]["images"][0]["extension"].stringValue
        
        let imageURL = URL(string: imagePath + "." + imageExtension)
        imageComic.image = try! UIImage(data: Data(contentsOf: imageURL!))
//        imageComic.load(url: imageURL!)
//        print(imageURL!)
        
        serieURL = json["data"]["results"][0]["series"]["resourceURI"].stringValue
//        print("serie url presa")
//        print(serieURL)
        
        let params2 : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH]
        getSerieData(url: serieURL!, parameters: params2)
        
        nameOfSerie = json["data"]["results"][0]["series"]["name"].stringValue
        
        self.issueNumber = json["data"]["results"][0]["issueNumber"].intValue
        self.parsedIdSerie = serieURL!.replacingOccurrences(of: "http://gateway.marvel.com/v1/public/series/", with: "")
        User.collection("Series").document("\(parsedIdSerie)").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let toRead = data!["issueToRead"] as! Int
                if toRead > self.issueNumber{
                    self.isRead = true
                    self.updateBtn()
                } else {
                    self.isRead = false
                    self.updateBtn()
                }
            } else {
                print("Document does not exist")
            }
        }
        group.leave()
    }
    
	//MARK: - Actions
	
	//TODO: completare con dati profilo
    
    func updateBtn(){
        if isRead == true{
            readButton.backgroundColor = UIColor(named: "DarkGreen")
            readButton.setTitle(NSLocalizedString("MARK AS UNREAD", comment: ""), for: .normal)
        } else {
            readButton.backgroundColor = UIColor(named: "Red")
            readButton.setTitle(NSLocalizedString("MARK AS READ", comment: ""), for: .normal)
        }
    }
	
	@objc func readIssueButton(button: UIButton) {
		isRead = !isRead

		if (isRead) {
			readButton.backgroundColor = UIColor(named: "DarkGreen")
			readButton.setTitle(NSLocalizedString("MARK AS UNREAD", comment: ""), for: .normal)
            User.collection("Series").document("\(parsedIdSerie)").setData([
                "id": parsedIdSerie,
                "image": imageSerie,
                "name": nameOfSerie,
                "issueToRead" : issueNumber + 1
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
		}
		else {
			readButton.backgroundColor = UIColor(named: "Red")
			readButton.setTitle(NSLocalizedString("MARK AS READ", comment: ""), for: .normal)
            User.collection("Series").document("\(parsedIdSerie)").setData([
                "id": parsedIdSerie,
                "image": imageSerie,
                "name": nameOfSerie,
                "issueToRead" : issueNumber - 1
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
		}
	}

	@objc func goToSeriesButton(button: UIButton) {
		self.performSegue(withIdentifier: "goToSeries", sender: self)
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SeriesViewController{
            
            destination.apiURL = serieURL

        }
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
