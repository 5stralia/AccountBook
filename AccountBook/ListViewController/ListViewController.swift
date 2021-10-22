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
    
    var dataSource: RxTableViewSectionedReloadDataSource<ListSection>?
    
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
            case .multipleDatePickerItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.multipleDatePickerItem.identifier, for: indexPath) as! ListInfoMultipleDatePickerCell
                cell.bind(to: viewModel)
                return cell
                
            case .datePickerItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.datePickerItem.identifier, for: indexPath) as! ListInfoDatePickerCell
                cell.bind(to: viewModel)
                return cell
                
             case .summaryItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.summaryItem.identifier, for: indexPath) as! ListInfoSummaryCell
                cell.bind(to: viewModel)
                return cell
                
            case .accountItem(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: CellItem.accountItem.identifier, for: indexPath) as! ListAccountCell
                
                cell.bind(to: viewModel)
                
                return cell
            }
        })
        
        self.dataSource = dataSource
        
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
        
        self.tableView.register(UINib(nibName: CellItem.multipleDatePickerItem.identifier, bundle: nil),
                                forCellReuseIdentifier: CellItem.multipleDatePickerItem.identifier)
        self.tableView.register(UINib(nibName: CellItem.datePickerItem.identifier, bundle: nil),
                                forCellReuseIdentifier: CellItem.datePickerItem.identifier)
        self.tableView.register(UINib(nibName: CellItem.summaryItem.identifier, bundle: nil),
                                forCellReuseIdentifier: CellItem.summaryItem.identifier)
        self.tableView.register(UINib(nibName: CellItem.accountItem.identifier, bundle: nil),
                                forCellReuseIdentifier: CellItem.accountItem.identifier)
        
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
        guard let dataSource = self.dataSource else { return .zero }
        
        let item = dataSource[indexPath]
        
        switch item {
        case .multipleDatePickerItem,
                .datePickerItem:
            return 42
        case .summaryItem:
            return 64
        case .accountItem:
            return 50
        }
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension ListViewController {
    enum CellItem {
        case multipleDatePickerItem
        case datePickerItem
        case summaryItem
        case accountItem
        
        var identifier: String {
            switch self {
            case .multipleDatePickerItem:
                return "ListInfoMultipleDatePickerCell"
            case .datePickerItem:
                return "ListInfoDatePickerCell"
            case .summaryItem:
                return "ListInfoSummaryCell"
            case .accountItem:
                return "ListAccountCell"
            }
        }
    }
}
