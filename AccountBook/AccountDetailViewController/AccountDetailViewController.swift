//
//  AccountDetailViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import RxCocoa
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
    
    private let textFieldCellIdentifier = "TextFieldCell"
    private let selectingCellIdentifier = "SelectingCell"
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: self.textFieldCellIdentifier, bundle: nil),
                                forCellReuseIdentifier: self.textFieldCellIdentifier)
        self.tableView.register(UITableViewCell.self,
                                forCellReuseIdentifier: self.selectingCellIdentifier)
        
        self.setNavigationItems()
    }
    
    private func bind(to viewModel: AccountDetailViewModel) {
        
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

extension AccountDetailViewController: UITableViewDelegate {
    
}

extension AccountDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.textFieldCellIdentifier) as! TextFieldCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.selectingCellIdentifier)!
            
            if #available(iOS 14.0, *) {
                var content = UIListContentConfiguration.valueCell()
                
                content.text = "text"
                content.secondaryText = "Second"
                
                cell.contentConfiguration = content
                
            } else {
                cell.textLabel?.text = "textLabel"
            }
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }
    }
}
