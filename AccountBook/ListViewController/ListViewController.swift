//
//  ListViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
                                       style: .plain,
                                       target: self,
                                       action: nil)
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let monthlyButton = UIBarButtonItem(title: "월별", style: .plain, target: self, action: nil)
    
    var viewModel: ListViewModel? {
        willSet {
            if let listViewModel = newValue {
                self.rx.viewDidLoad
                    .subscribe(onNext: { [weak self] in
                        self?.bind(to: listViewModel)
                    })
                    .disposed(by: self.disposeBag)
            }
        }
    }
    
    private let infoCellIdentifier = "ListInfoCell"
    private let cellIdentifier = "ListAccountCell"
    
    var disposeBag = DisposeBag()
    
    private func bind(to viewModel: ListViewModel) {
        self.addButton.rx.tap.asDriver().drive(onNext: { [weak self] in
            let accountDetailViewController = AccountDetailViewController()
            let accountDetailViewModel = AccountDetailViewModel(provider: self!.viewModel!.provider)
            accountDetailViewController.viewModel = accountDetailViewModel
            let navigationController = UINavigationController(rootViewController: accountDetailViewController)
            self?.present(navigationController, animated: true, completion: nil)
        })
            .disposed(by: self.disposeBag)
        
        let output = viewModel.transform(input: ListViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.asObservable().map { _ in },
            changeMonthly: self.monthlyButton.rx.tap.asObservable().map { _ in }))
        
        let dataSource = RxTableViewSectionedReloadDataSource<ListSection>(configureCell: { dataSource, tableView, indexPath, item in
            switch item {
            case .infoItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: self.infoCellIdentifier, for: indexPath) as! ListInfoCell
                
                return cell
                
            case .accountItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! ListAccountCell
                
                cell.bind(to: viewModel)
                
                return cell
            }
        })
        
        output.items
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        output.isMonthly.asObservable()
            .map { $0 ? "월간" : "일간" }
            .bind(to: self.monthlyButton.rx.title)
            .disposed(by: self.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: self.infoCellIdentifier, bundle: nil),
                                forCellReuseIdentifier: self.infoCellIdentifier)
        self.tableView.register(UINib(nibName: self.cellIdentifier, bundle: nil),
                                forCellReuseIdentifier: self.cellIdentifier)
        
        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        
        self.navigationItem.rightBarButtonItems = [self.addButton, self.monthlyButton, self.filterButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    @objc private func addAccount() {
        let accountDetailViewController = AccountDetailViewController()
        let accountDetailViewModel = AccountDetailViewModel(provider: self.viewModel!.provider)
        accountDetailViewController.viewModel = accountDetailViewModel
        let navigationController = UINavigationController(rootViewController: accountDetailViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 122
        } else {
            return 50
        }
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
