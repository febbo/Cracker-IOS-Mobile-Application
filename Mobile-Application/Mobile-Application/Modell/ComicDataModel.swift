//
//  ComicDataModel.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 12/08/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation


class ComicDataModel{
    //Declare your model variables here
    var id : Int?
    var title : String = ""
    var issueNumber : Int = 0
    var pageCount : Int = 0
    var resourceURI : String = ""
    var serie : Serie?
    var onSaleDate : Date?
    var description : String = ""
    
    //per avere immagine path + https://developer.marvel.com/documentation/images + . + extension
    var image : ImageIssue?
    
    var creators : [Creator] = []
    
    var charactersURI : String = ""
    var storiesURI : String = ""
    var eventsURI : String = ""
    
    init(id: Int, title: String, issueNumber: Int, onsaleDate: Date, serie: Serie, image: ImageIssue, creators: [Creator], description: String){
        self.id = id
        self.title = title
        self.issueNumber = issueNumber
        self.onSaleDate = onsaleDate
        self.serie = serie
        self.image = image
        self.creators = creators
        self.description = description
    }
    
    
}
