//
//  UserSeriesCollectionViewController.swift
//  Mobile-Application
//
//  Created by Elisabetta on 18/11/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import UIKit

class UserSeriesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
	var cellSize: CGSize?
    var imageSize: CGSize?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let collectionViewSize = collectionView.frame.size.width - 60
		if (traitCollection.horizontalSizeClass == .regular) {
			cellSize = CGSize(width: collectionViewSize/3, height: collectionViewSize/3)
            imageSize = CGSize(width: collectionViewSize/3 - 15, height: collectionViewSize/3 - 15)
		}
		else {
			cellSize = CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
            imageSize = CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
		}
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserSeriesCell", for: indexPath) as! UserSeriesCollectionViewCell
        let img = UIImage(named: "series")!.resized(to: imageSize!)
        cell.seriesImage.setBackgroundImage(img, for: UIControl.State.normal)
        cell.seriesImage.addTarget(self, action: #selector(showSeries), for: UIControl.Event.touchUpInside)
    
        return cell
    }

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
		return cellSize!
    }
    
    @objc func showSeries(button: UIButton) {
        self.performSegue(withIdentifier: "ShowSeriesFromProfile", sender: self)
    }
	
}

public extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
