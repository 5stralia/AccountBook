//
//  PieChartViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/27.
//

import UIKit

import Charts
import RxCocoa
import RxSwift

class PieChartViewController: ViewController {
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var barChartCollectionView: UICollectionView!
    @IBOutlet weak var outterProgressBar: UIView!
    @IBOutlet weak var innerProgressBar: UIView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var outterAmountLabel: UILabel!
    @IBOutlet weak var innerAmountLabel: UILabel!
    
    @IBOutlet weak var innerProgressBarWidthConstraint: NSLayoutConstraint!
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? PieChartViewModel else { return }
        
        let output = viewModel.transform(input: PieChartViewModel.Input())
        
        output.pieItems.asDriver()
            .drive(onNext: {
                guard !$0.isEmpty else { return }
                
                let dataSet = PieChartDataSet(entries: $0)
                dataSet.colors = ChartColorTemplates.pastel()
                dataSet.sliceSpace = 2
                dataSet.valueFormatter = PercentageFormatter()
                dataSet.xValuePosition = .outsideSlice
                dataSet.yValuePosition = .outsideSlice
                dataSet.valueTextColor = .black
                
                let data = PieChartData(dataSet: dataSet)
                
                self.pieChartView.data = data
                
                self.pieChartView.notifyDataSetChanged()
            })
            .disposed(by: self.disposeBag)
        
        output.progress
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { (isOverIncome, income, expenditure) in
                if isOverIncome {
                    self.innerProgressBar.backgroundColor = .red
                    self.innerAmountLabel.text = expenditure.priceString()
                    
                    self.outterProgressBar.backgroundColor = .blue
                    self.outterAmountLabel.text = income.priceString()
                    
                    self.totalAmountLabel.textColor = .blue
                    
                    self.innerProgressBarWidthConstraint.constant = income > 0
                    ? (CGFloat(expenditure) / CGFloat(income)) * self.outterProgressBar.bounds.width
                    : 0
                } else {
                    self.innerProgressBar.backgroundColor = .blue
                    self.innerAmountLabel.text = income.priceString()
                    
                    self.outterProgressBar.backgroundColor = .red
                    self.outterAmountLabel.text = expenditure.priceString()
                    
                    self.totalAmountLabel.textColor = .red
                    
                    self.innerProgressBarWidthConstraint.constant = expenditure > 0
                    ? (CGFloat(income) / CGFloat(expenditure)) * self.outterProgressBar.bounds.width
                    : 0
                }
                
                let totalAmount = income - expenditure
                self.totalAmountLabel.text = totalAmount.priceString()
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pieChartView.rotationEnabled = false
        self.pieChartView.legend.enabled = false
        self.pieChartView.highlightPerTapEnabled = false
        self.pieChartView.setExtraOffsets(left: 10, top: 10, right: 10, bottom: 10)
        self.pieChartView.noDataText = "비어있음"
        self.pieChartView.noDataFont = .systemFont(ofSize: 20, weight: .bold)
    }

}

class PercentageFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "\(Int(value))%"
    }
}

extension PieChartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 24)
    }
}
