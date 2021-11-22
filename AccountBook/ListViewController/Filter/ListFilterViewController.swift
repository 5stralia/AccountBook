//
//  ListFilterViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/28.
//

import UIKit

import RxCocoa
import RxSwift

class ListFilterViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "AccountDetailSelectionCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        
        self.tableView.register(UINib(nibName: self.cellIdentifier, bundle: nil),
                                forCellReuseIdentifier: self.cellIdentifier)
    }

    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ListFilterViewModel else { return }
        
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)

        let output = viewModel.transform(input: ListFilterViewModel.Input(
            selection: self.tableView.rx.modelSelected(AccountDetailSelectionCellViewModel.self).asObservable()
        ))
        
        output.items.bind(to: self.tableView.rx.items(
            cellIdentifier: self.cellIdentifier,
            cellType: AccountDetailSelectionCell.self)) { row, element, cell in
                cell.bind(to: element)
            }
            .disposed(by: self.disposeBag)
        
        output.selectDetail.subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selectingViewModel in
                let selectingViewController = AccountDetailSelectingViewController()
                selectingViewController.viewModel = selectingViewModel
                
                self?.navigationController?.pushViewController(selectingViewController, animated: true)
            })
            .disposed(by: self.disposeBag)
    }

}
