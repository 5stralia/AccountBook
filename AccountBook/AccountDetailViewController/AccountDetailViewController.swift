//
//  AccountDetailViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

class AccountDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationItems()
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
