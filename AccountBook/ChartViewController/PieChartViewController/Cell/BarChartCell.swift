//
//  BarChartCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/28.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class BarChartCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBarBackgroundView: UIView!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

}
