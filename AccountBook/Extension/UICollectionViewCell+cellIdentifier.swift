//
//  UICollectionViewCell+cellIdentifier.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/29.
//

import UIKit

extension UICollectionViewCell {
    class var cellIdentifier: String { return String(describing: self) }
}
