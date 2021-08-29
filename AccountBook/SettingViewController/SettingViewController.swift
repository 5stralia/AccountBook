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

class SettingViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: SettingViewModel?
    
    var disposeBag = DisposeBag()
    
    private let tableViewCellIdentifier = "TableViewCell"
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: self.tableViewCellIdentifier, bundle: nil),
                                forCellReuseIdentifier: self.tableViewCellIdentifier)
        
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        guard let viewModel = self.viewModel else { return }
        
        let didSelect = self.tableView.rx.modelSelected(SettingSectionItem.self).asDriver()
        
        let output = viewModel.transform(input: SettingViewModel.Input(refresh: Observable.just(()), didSelect: didSelect))
        
        let dataSource = RxTableViewSectionedReloadDataSource<SettingSection> { dataSource, tableView, indexPath, item in
            switch item {
            case .logOutItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: self.tableViewCellIdentifier,
                                                         for: indexPath) as! TableViewCell
                cell.bind(to: viewModel)
                return cell
            }
        }
        
        output.items
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        output.signOut
            .subscribe(onNext: { [weak self] in
                let alertControl = UIAlertController(title: nil, message: "로그아웃 완료", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in 
                    let signInViewController = SignInViewController()
                    signInViewController.modalPresentationStyle = .fullScreen
                    self?.present(signInViewController, animated: true, completion: nil)
                }
                alertControl.addAction(okAction)
                self?.present(alertControl, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
}
