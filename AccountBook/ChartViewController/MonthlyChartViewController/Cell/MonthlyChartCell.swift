//
//  MonthlyChartCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

class MonthlyChartCell: UICollectionViewCell {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var barBackgroundView: UIView!
    
    @IBOutlet weak var barHeightConstraint: NSLayoutConstraint!
    
}
