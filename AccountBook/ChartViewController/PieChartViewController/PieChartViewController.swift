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
        self.updatePieChart()
    }
    
    private func updatePieChart() {
        let entry1 = PieChartDataEntry(value: 40, label: "#1")
        let entry2 = PieChartDataEntry(value: 30, label: "#2")
        let entry3 = PieChartDataEntry(value: 20, label: "#3")
        let entry4 = PieChartDataEntry(value: 10, label: "#4")
        
        let dataSet = PieChartDataSet(entries: [entry1, entry2,entry3,entry4])
        dataSet.setColors(UIColor.red, UIColor.blue, UIColor.black, UIColor.cyan, UIColor.yellow)
        let data = PieChartData(dataSet: dataSet)
        
        self.pieChartView.data = data
        
        self.pieChartView.notifyDataSetChanged()
    }

}
