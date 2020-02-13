//
//  SearchTableViewController.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 12/02/2020.
//  Copyright © 2020 Leonardo Febbo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SearchTableViewController: UITableViewController {

    var selectedCellIndex : Int = 0
    
    private var searchResults = [JSON]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let apiFetcher = APIRequestFetcher()
    private var previousRun = Date()
    private let minInterval = 0.05
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
//        setupTableViewBackgroundView()
        setupSearchBar()

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "DarkGreen")

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationItem.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = self.searchController
        self.definesPresentationContext = true
        
        self.hideKeyboardWhenTappedAround()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    // MARK: - Search Functions
    private func setupSearchBar() {
        searchController.searchBar.delegate = self as! UISearchBarDelegate
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search for a serie", comment: "")
        definesPresentationContext = true
    }
    
//    private func setupTableViewBackgroundView() {
//        let backgroundViewLabel = UILabel(frame: .zero)
//        backgroundViewLabel.textColor = .darkGray
//        backgroundViewLabel.numberOfLines = 0
//        backgroundViewLabel.text = NSLocalizedString("Oops,\nno results to show!", comment: "")
//        backgroundViewLabel.textAlignment = NSTextAlignment.center
//        tableView.backgroundView = backgroundViewLabel
//    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell

        
        // Configure the cell...
        cell.textLabel?.text = searchResults[indexPath.row]["title"].stringValue
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCellIndex = indexPath.row
        self.performSegue(withIdentifier: "SearchToSerie", sender: self)

    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? SeriesViewController{

            let url = searchResults[selectedCellIndex]["resourceURI"].stringValue
            destination.apiURL = url

        }
    }

}

extension UITableViewController {

   func hideKeyboardWhenTappedAround() {
       let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UITableViewController.dismissKeyboard(_:)))
       tap.cancelsTouchesInView = false
       view.addGestureRecognizer(tap)
   }

   @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
       view.endEditing(true)

       if let nav = self.navigationController {
           nav.view.endEditing(true)
       }
   }
}

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults.removeAll()
        guard let textToSearch = searchBar.text, !textToSearch.isEmpty else {
            return
        }
        
        if Date().timeIntervalSince(previousRun) > minInterval {
            previousRun = Date()
            fetchResults(for: textToSearch)
        }
    }
    
    func fetchResults(for text: String) {
        print("Text Searched: \(text)")
        apiFetcher.search(searchText: text, completionHandler: {
            [weak self] results, error in
            if case .failure = error {
                return
            }
            
            guard let results = results, !results.isEmpty else {
                return
            }
            
            self?.searchResults = results
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults.removeAll()
    }

}

