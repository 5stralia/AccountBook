//
//  ListInfoDatePickerCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/22.
//

import UIKit

import RxCocoa
import RxSwift

class ListInfoDatePickerCell: UITableViewCell {
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: ListInfoDatePickerCellViewModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 MM월"
        
        viewModel.date
            .compactMap { $0 }
            .map { dateFormatter.string(from: $0) }
            .bind(to: self.dateButton.rx.title())
            .disposed(by: self.disposeBag)
    }
    
}
