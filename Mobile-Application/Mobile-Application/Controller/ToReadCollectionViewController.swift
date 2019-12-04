//
//  ToReadCollectionViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 04/12/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit

class ToReadCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var cellSize: CGSize?
    var imageSize: CGSize?
    
    let aspectRatio: CGFloat = 251/162

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionViewSize = collectionView.frame.size.width - 60
        if (traitCollection.horizontalSizeClass == .regular) {
            cellSize = CGSize(width: collectionViewSize/3, height: collectionViewSize/3 * aspectRatio)
            imageSize = CGSize(width: collectionViewSize/3 - 15, height: (collectionViewSize/3 - 15) * aspectRatio)
        }
        else {
            cellSize = CGSize(width: collectionViewSize/2, height: collectionViewSize/2 * aspectRatio)
            imageSize = CGSize(width: collectionViewSize/2, height: collectionViewSize/2 * aspectRatio)
        }

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
        
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToReadCell", for: indexPath) as! ToReadCollectionViewCell
        let img = UIImage(named: "issue")!.resized(to: imageSize!)
        cell.issueImage.image = img
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return cellSize!
    }

}


class ToReadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var issueImage: UIImageView!
    
}
