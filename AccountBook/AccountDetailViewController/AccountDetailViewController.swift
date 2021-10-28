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

class AccountDetailViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
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
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? AccountDetailViewModel else { return }
        
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        let output = viewModel.transform(input: AccountDetailViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.asObservable().map { _ in },
            selection: self.tableView.rx.modelSelected(AccountDetailSectionItem.self).asObservable(),
            submit: self.navigationItem.rightBarButtonItem!.rx.tap.asObservable()))
        
        output.isEnabledDoneButton.bind(to: self.navigationItem.rightBarButtonItem!.rx.isEnabled).disposed(by: self.disposeBag)
        
        output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        output.selectSubItem
            .subscribe(onNext: { [weak self] item in
                guard let selectingViewModel = item else { return }
                
                let selectingViewController = AccountDetailSelectingViewController()
                selectingViewController.viewModel = selectingViewModel
                self?.navigationController?.pushViewController(selectingViewController, animated: true)
            })
            .disposed(by: self.disposeBag)
        
        let datasource = RxTableViewSectionedReloadDataSource<AccountDetailSection>(configureCell: { datasource, tableView, indexPath, item in
            switch item {
            case .titleItem(let viewModel),
                    .amountItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.textField.identifier, for: indexPath) as! TextFieldCell
                cell.bind(to: viewModel)
                return cell
                
            case .categoryItem(let viewModel),
                    .payerItem(let viewModel),
                    .participantItem(let viewModel):
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
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
