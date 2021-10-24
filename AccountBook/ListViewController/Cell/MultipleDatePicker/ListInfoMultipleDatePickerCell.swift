//
//  ListInfoMultipleDatePickerCell.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/22.
//

import UIKit

import RxCocoa
import RxSwift

class ListInfoMultipleDatePickerCell: UITableViewCell {
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    func bind(to viewModel: ListInfoMultipleDatePickerCellViewModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY.MM.dd"
        
        viewModel.startDate
            .compactMap({ $0 })
            .map({ dateFormatter.string(from: $0 )})
            .bind(to: self.startDateButton.rx.title())
            .disposed(by: self.disposeBag)
        viewModel.endDate
            .compactMap({ $0 })
            .map({ dateFormatter.string(from: $0 )})
            .bind(to: self.endDateButton.rx.title())
            .disposed(by: self.disposeBag)
    }
    
}
