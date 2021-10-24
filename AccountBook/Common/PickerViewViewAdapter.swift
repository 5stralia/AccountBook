//
//  PickerViewViewAdapter.swift
//  AccountBook
//
//  Created by 최호주 on 2021/10/24.
//

import UIKit

import RxCocoa
import RxSwift

final class PickerViewViewAdapter<T: CustomStringConvertible>
: NSObject
, UIPickerViewDataSource
, UIPickerViewDelegate
, RxPickerViewDataSourceType
, SectionedViewDataSourceType {
    typealias Element = [[T]]
    private var items: Element = []
    
    func model(at indexPath: IndexPath) throws -> Any {
        items[indexPath.section][indexPath.row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = items[component][row].description
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        Binder(self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
        }.on(observedEvent)
    }
}
