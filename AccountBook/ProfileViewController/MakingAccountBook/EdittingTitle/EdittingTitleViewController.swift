//
//  EdittingTitleViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/30.
//

import UIKit

class EdittingTitleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
    }
    
}

extension EdittingTitleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let edittingGroupViewController = EdittingGroupViewController()
        self.navigationController?.pushViewController(edittingGroupViewController, animated: true)
        
        return true
    }
}
