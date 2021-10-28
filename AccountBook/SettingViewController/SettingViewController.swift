//
//  SettingViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class SettingViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let tableViewCellIdentifier = "TableViewCell"
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: self.tableViewCellIdentifier, bundle: nil),
                                forCellReuseIdentifier: self.tableViewCellIdentifier)
    }
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? SettingViewModel else { return }
        
        let didSelect = self.tableView.rx.modelSelected(SettingSectionItem.self).asDriver()
        
        let output = viewModel.transform(input: SettingViewModel.Input(refresh: Observable.just(()), didSelect: didSelect))
        
        let dataSource = RxTableViewSectionedReloadDataSource<SettingSection>(configureCell: { dataSource, tableView, indexPath, item in
            switch item {
            case .logOutItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: self.tableViewCellIdentifier,
                                                         for: indexPath) as! TableViewCell
                cell.bind(to: viewModel)
                return cell
            }
        }, titleForHeaderInSection: { dataSource, index in
            let section = dataSource[index]
            return section.title
        })
        
        output.items
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
    }
}
