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
    private var pickerBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private var pickerView = UIPickerView()
    private var pickerDoneButton = UIButton(type: .system)
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
    
    let selectedYearIndex = BehaviorRelay<Int>(value: 0)
    let selectedMonthIndex = BehaviorRelay<Int>(value: 0)
    
    var dataSource: RxTableViewSectionedReloadDataSource<ListSection>?
    
    var disposeBag = DisposeBag()
    
    private func bind(to viewModel: ListViewModel) {
        self.pickerView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] in
                if $0.component == 0 {
                    self?.selectedYearIndex.accept($0.row)
                } else {
                    self?.selectedMonthIndex.accept($0.row)
                }
            })
            .disposed(by: self.disposeBag)
        
        self.addButton.rx.tap.asDriver().drive(onNext: { [weak self] in
            let accountDetailViewController = AccountDetailViewController()
            let accountDetailViewModel = AccountDetailViewModel(provider: self!.viewModel!.provider)
            accountDetailViewController.viewModel = accountDetailViewModel
            let navigationController = UINavigationController(rootViewController: accountDetailViewController)
            self?.present(navigationController, animated: true, completion: nil)
        })
            .disposed(by: self.disposeBag)
        
        let selectedDatePickerItem = self.pickerDoneButton.rx.tap.asObservable()
            .map { [weak self] in
                (yearIndex: self?.selectedYearIndex.value ?? 0, monthIndex: self?.selectedMonthIndex.value ?? 0)
            }
        
        let output = viewModel.transform(input: ListViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.asObservable().map { _ in },
            changeMonthly: self.monthlyButton.rx.tap.asObservable().map { _ in },
            selectedDatePickerItem: selectedDatePickerItem))
        
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
        
        output.showYearMonthPicker.asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.showPickerView()
            })
            .disposed(by: self.disposeBag)
        
        output.yearMonthPickerItems
            .bind(to: self.pickerView.rx.items(adapter: PickerViewViewAdapter<Int>()))
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(output.yearMonthPickerItems, output.startDate.asObservable()) { items, startDate in
            let yearIndex = items[0].firstIndex(of: Calendar.current.component(.year, from: startDate))
            let monthIndex = items[1].firstIndex(of: Calendar.current.component(.month, from: startDate))
            
            return (yearIndex ?? 0, monthIndex ?? 0)
        }
        .asDriver(onErrorJustReturn: (0, 0))
        .drive(onNext: { [weak self] (year, month) in
            self?.pickerView.selectRow(year, inComponent: 0, animated: false)
            self?.pickerView.selectRow(month, inComponent: 1, animated: false)
        })
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
    
    private func showPickerView() {
        guard let tabBarController = self.tabBarController else { return }
        
        tabBarController.view.addSubview(self.pickerBackgroundView)
        self.pickerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pickerBackgroundView.leadingAnchor.constraint(equalTo: tabBarController.view.leadingAnchor),
            self.pickerBackgroundView.topAnchor.constraint(equalTo: tabBarController.view.topAnchor),
            self.pickerBackgroundView.trailingAnchor.constraint(equalTo: tabBarController.view.trailingAnchor),
            self.pickerBackgroundView.bottomAnchor.constraint(equalTo: tabBarController.view.bottomAnchor)
        ])
        
        self.pickerBackgroundView.contentView.addSubview(self.pickerView)
        self.pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pickerView.leadingAnchor.constraint(equalTo: self.pickerBackgroundView.leadingAnchor),
            self.pickerView.trailingAnchor.constraint(equalTo: self.pickerBackgroundView.trailingAnchor),
            self.pickerView.bottomAnchor.constraint(equalTo: self.pickerBackgroundView.bottomAnchor)
        ])
        
        self.pickerDoneButton.setTitle("Done", for: .normal)
        self.pickerDoneButton.rx.tap.asDriver().drive(onNext: { [weak self] in
            self?.hidePickerView()
        })
            .disposed(by: self.disposeBag)
        
        self.pickerBackgroundView.contentView.addSubview(self.pickerDoneButton)
        self.pickerDoneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pickerDoneButton.leadingAnchor.constraint(equalTo: self.pickerBackgroundView.leadingAnchor),
            self.pickerDoneButton.trailingAnchor.constraint(equalTo: self.pickerBackgroundView.trailingAnchor),
            self.pickerDoneButton.bottomAnchor.constraint(equalTo: self.pickerView.topAnchor),
            self.pickerDoneButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    
    private func hidePickerView() {
        self.pickerView.removeFromSuperview()
        self.pickerBackgroundView.removeFromSuperview()
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
