//
//  AdjustmentChartViewController.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/22.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class AdjustmentChartViewController: ViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "개인별 정산"
        label.font = .systemFont(ofSize: 19)
        label.textColor = .label
        
        return label
    }()
    private let collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = .init(leading: .fixed(0), top: .fixed(0), trailing: .fixed(0), bottom: .fixed(10))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(110))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()

    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? AdjustmentChartViewModel else { return }
        
        let output = viewModel.transform(input: AdjustmentChartViewModel.Input())
        
        output.items.asDriver()
            .drive(self.collectionView.rx.items(cellIdentifier: AdjustmentChartCell.cellIdentifier,
                                                cellType: AdjustmentChartCell.self))
        { row, element, cell in
            cell.bind(to: element)
        }
        .disposed(by: self.disposeBag)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(AdjustmentChartCell.self,
                                     forCellWithReuseIdentifier: AdjustmentChartCell.cellIdentifier)
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(40)
        }
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-15)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(10)
        }
    }

}
