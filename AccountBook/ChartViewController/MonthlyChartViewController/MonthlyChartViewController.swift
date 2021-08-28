//
//  MonthlyChartViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/28.
//

import UIKit
import Charts

class MonthlyChartViewController: UIViewController {
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "MonthlyChartCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(UINib(nibName: self.cellIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: self.cellIdentifier)
    }
}

extension MonthlyChartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 10
        let width = (collectionView.bounds.width - (4 * space)) / 5
        return CGSize(width: width, height: collectionView.bounds.height)
    }
}

extension MonthlyChartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! MonthlyChartCell
        
        return cell
    }
}
