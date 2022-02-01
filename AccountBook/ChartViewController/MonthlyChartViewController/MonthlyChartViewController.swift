//
//  MonthlyChartViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/28.
//

import UIKit
import Charts

import RxCocoa
import RxSwift

class MonthlyChartViewController: ViewController {
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? MonthlyChartViewModel else { return }
        
        let output = viewModel.transform(input: MonthlyChartViewModel.Input())
        
        output.items.asDriver()
            .drive(self.collectionView.rx.items(cellIdentifier: MonthlyChartCell.cellIdentifier,
                                                cellType: MonthlyChartCell.self)) { index, element, cell in
                cell.bind(to: element)
            }
                                                .disposed(by: self.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(UINib(nibName: MonthlyChartCell.cellIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: MonthlyChartCell.cellIdentifier)
        self.collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
    }
    
}

extension MonthlyChartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 10
        let width = (collectionView.bounds.width - (4 * space)) / 5
        return CGSize(width: width, height: collectionView.bounds.height)
    }
}
