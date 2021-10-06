//
//  AccountDetailSelectingViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/30.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift

class AccountDetailSelectingViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "AccountDetailSelectingCell"
    
    var viewModel: AccountDetailSelectingViewModel? {
        willSet {
            if let accountDetailSelectingViewModel = newValue {
                self.rx.viewDidLoad
                    .subscribe(onNext: {
                        self.bind(to: accountDetailSelectingViewModel)
                    })
                    .disposed(by: self.disposeBag)
            }
        }
    }
    
    var disposeBag = DisposeBag()

    private func bind(to viewModel: AccountDetailSelectingViewModel) {
        let output = viewModel.transform(input: AccountDetailSelectingViewModel.Input(selection: self.tableView.rx.modelSelected(AccountDetailSelectingSectionItem.self).asObservable()))
        
        let datasource = RxTableViewSectionedReloadDataSource<AccountDetailSelectingSection>(configureCell: { datasource, tableView, indexPath, item in
            switch item {
            case .titleItem(let viewModel),
                    .addingItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! AccountDetailSelectingCell
                cell.bind(to: viewModel)
                return cell
            }
        })
        
        output.items.bind(to: self.tableView.rx.items(dataSource: datasource)).disposed(by: self.disposeBag)
        
        output.selectedEvent
            .subscribe(onNext: { [weak self] item in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: self.cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
    }
    
}