//
//  BarChartViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/28.
//

import UIKit
import Charts

class BarChartViewController: UIViewController {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "BarChartCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(UINib(nibName: self.cellIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: self.cellIdentifier)
    }

}

extension BarChartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 24)
    }
}

extension BarChartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! BarChartCell
        
        return cell
    }
}
