//
//  AccountDetailViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift

class AccountDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: AccountDetailViewModel? {
        willSet {
            if let accountDetailViewModel = newValue {
                self.rx.viewDidLoad.subscribe(onNext: {
                    self.bind(to: accountDetailViewModel)
                })
                    .disposed(by: self.disposeBag)
            }
        }
    }
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: CellItem.textField.identifier, bundle: nil),
                                forCellReuseIdentifier: CellItem.textField.identifier)
        self.tableView.register(UINib(nibName: CellItem.selection.identifier, bundle: nil),
                                forCellReuseIdentifier: CellItem.selection.identifier)
        self.tableView.register(UINib(nibName: CellItem.date.identifier, bundle: nil),
                                forCellReuseIdentifier: CellItem.date.identifier)
        self.tableView.register(UINib(nibName: CellItem.segment.identifier, bundle: nil),
                                forCellReuseIdentifier: CellItem.segment.identifier)
        
        self.setNavigationItems()
    }
    
    private func bind(to viewModel: AccountDetailViewModel) {
        let output = viewModel.transform(input: AccountDetailViewModel.Input())
        
        let datasource = RxTableViewSectionedReloadDataSource<AccountDetailSection>(configureCell: { datasource, tableView, indexPath, item in
            switch item {
            case .textfieldItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.textField.identifier, for: indexPath) as! TextFieldCell
                cell.bind(to: viewModel)
                return cell
                
            case .selectionItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.selection.identifier, for: indexPath) as! AccountDetailSelectionCell
                cell.bind(to: viewModel)
                return cell
                
            case .multiSelectionItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.selection.identifier, for: indexPath) as! AccountDetailSelectionCell
                cell.bind(to: viewModel)
                return cell
                
            case .dateItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.date.identifier, for: indexPath) as! AccountDetailDateCell
                cell.bind(to: viewModel)
                return cell
                
            case .segmentItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.segment.identifier, for: indexPath) as! AccountDetailSegmentCell
                cell.bind(to: viewModel)
                return cell
            }
        })
        
        output.items
            .bind(to: self.tableView.rx.items(dataSource: datasource))
            .disposed(by: self.disposeBag)
    }
    
    private func setNavigationItems() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.close))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let submitButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close))
        self.navigationItem.rightBarButtonItem = submitButton
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func submit() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension AccountDetailViewController {
    enum CellItem {
        case textField
        case selection
        case date
        case segment
        
        var identifier: String {
            switch self {
            case .textField: return "TextFieldCell"
            case .selection: return "AccountDetailSelectionCell"
            case .date: return "AccountDetailDateCell"
            case .segment: return "AccountDetailSegmentCell"
            }
        }
    }
}
