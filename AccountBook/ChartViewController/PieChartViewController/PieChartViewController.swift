//
//  PieChartViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/27.
//

import UIKit
import Charts

class PieChartViewController: UIViewController {
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pieChartView.rotationEnabled = false
        self.pieChartView.legend.enabled = false
        self.pieChartView.highlightPerTapEnabled = false
        self.pieChartView.setExtraOffsets(left: 10, top: 10, right: 10, bottom: 10)
        
        self.updatePieChart()
    }
    
    private func updatePieChart() {
        let entries = [
            PieChartDataEntry(value: 40, label: "#1"),
            PieChartDataEntry(value: 30, label: "#2"),
            PieChartDataEntry(value: 20, label: "#3"),
            PieChartDataEntry(value: 5, label: "#4"),
            PieChartDataEntry(value: 1, label: "#5"),
            PieChartDataEntry(value: 1, label: "#6"),
            PieChartDataEntry(value: 1, label: "#7"),
            PieChartDataEntry(value: 1, label: "#8"),
            PieChartDataEntry(value: 1, label: "#9")
        ]
        
        let dataSet = PieChartDataSet(entries: entries)
        dataSet.colors = ChartColorTemplates.pastel()
        dataSet.sliceSpace = 2
        dataSet.valueFormatter = PercentageFormatter()
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.valueTextColor = .black
        
        let data = PieChartData(dataSet: dataSet)
        
        self.pieChartView.data = data
        
        self.pieChartView.notifyDataSetChanged()
    }

}

class PercentageFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "\(Int(value))%"
    }
}
