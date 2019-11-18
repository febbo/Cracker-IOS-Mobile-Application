//
//  UserSeriesCollectionViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 18/11/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "UserSeriesCell"

class UserSeriesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 7
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
		cell.backgroundColor = .red
    
        return cell
    }

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.frame.size.width - 60
		
		if (traitCollection.horizontalSizeClass == .regular) {
			return CGSize(width: collectionViewSize/3, height: collectionViewSize/3)
		}
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
	
}
