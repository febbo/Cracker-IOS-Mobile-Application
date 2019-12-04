//
//  leo.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 30/09/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation

//var UpNextComics : [[ComicDataModel]] = [[]]
//
//        var comics : [ComicDataModel] = []


//                let id = json["data"]["results"][i]["id"].intValue
//                let title = json["data"]["results"][i]["title"].stringValue
//                let issueNumber = json["data"]["results"][i]["issueNumber"].intValue
//
//                let onSaleDate = json["data"]["results"][i]["dates"][0]["date"].stringValue
//
////                let dateFormatter = DateFormatter()
////                dateFormatter.dateFormat = "dd-mm-yyyy" //Your date format
////                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
////
////                guard let date = dateFormatter.date(from: onSaleDate) else {
////                    fatalError()
////                }
//
//                let serieUri = json["data"]["results"][i]["series"]["resourceURI"].stringValue
//                let serieName = json["data"]["results"][i]["series"]["name"].stringValue
//                let serie = SerieDataModel(URI: serieUri,  name: serieName)
//
//                let imagePath = json["data"]["results"][i]["images"][0]["path"].stringValue
//                let imageExt = json["data"]["results"][i]["images"][0]["extension"].stringValue
//                let image = ImageIssueDataModel(path: imagePath, ext: imageExt)
//
//                var creators : [CreatorDataModel] = []
//                let creatorsAvailable = json["data"]["results"][i]["creators"]["available"].intValue
//                for j in 0...creatorsAvailable{
//                    let creatorURI = json["data"]["results"][i]["creators"]["items"][j]["resourceURI"].stringValue
//                    let creatorName = json["data"]["results"][i]["creators"]["items"][j]["name"].stringValue
//                    let creatorRole = json["data"]["results"][i]["creators"]["items"][j]["role"].stringValue
//                    let creator = CreatorDataModel(URI: creatorURI, name: creatorName, role: creatorRole)
//
//                    creators.append(creator)
//
//                }
//
//                let description = json["data"]["results"][i]["description"].stringValue
////                if description == "" {
////                    description = ""
////                }
//
//                let comic = ComicDataModel(id: id, title: title, issueNumber: issueNumber, onSaleDate: onSaleDate, serie: serie, image: image, creators: creators, description: description)
//
//
//                comics.append(comic)



//        //Controllare quali issues letti
//        User.collection("Series").document("\(self.serieID)").getDocument { (document, error) in
//            if let document = document, document.exists {
//                let data = document.data()
//                var read = data!["issueToRead"] as! Int
//                read = read - 1
//                print("number of issues read : \(read)")
//                let n_sections = read / 10
//                print("number of sections: \(n_sections)")
//                let n_issues_last_section = read % 10
//                print("number of last issues: \(n_issues_last_section)")
//                if n_sections != 0{
//                    for i in 0...n_sections-1{
//                        for j in 0...9{
//                            let cell = self.tableView(self.issuesTable, cellForRowAt: [i, j]) as! IssuesInSeriesTableViewCell
//                            self.switchReadStatus(button: cell.readButton)
//                        }
//                    }
//                    for j in 0...n_issues_last_section-1{
//                        let cell = self.tableView(self.issuesTable, cellForRowAt: [n_sections+1, j]) as! IssuesInSeriesTableViewCell
//                        self.switchReadStatus(button: cell.readButton)
//                    }
//                } else {
//                    for j in 0...n_issues_last_section-1{
//                        let cell = self.tableView(self.issuesTable, cellForRowAt: [0, j]) as! IssuesInSeriesTableViewCell
////                        print(cell.label.text!)
////                        print(cell.readButton.isSelected)
////                        cell.readButton.isSelected = true
////                        self.switchReadStatus(button: cell.readButton)
////                        print(cell.readButton.isSelected)
//
//                    }
//                }
//            } else {
//                print("Document does not exist")
//            }
//        }
