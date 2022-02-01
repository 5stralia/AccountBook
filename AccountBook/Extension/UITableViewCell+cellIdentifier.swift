//
//  UITableViewCell+cellIdentifier.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/29.
//

import UIKit

extension UITableViewCell {
    class var cellIdentifier: String { return String(describing: self) }
}
