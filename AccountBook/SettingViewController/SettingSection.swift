//
//  SettingSection.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

import RxDataSources

enum SettingSection {
    case profile(title: String, items: [SettingSectionItem])
}

enum SettingSectionItem {
//    case profileItem(viewModel: SettingProfileViewModel)
    case logOutItem(viewModel: TableViewCellViewModel)
}

extension SettingSectionItem: IdentifiableType {
    typealias Identity = String
    
    var identity: Identity {
        switch self {
        case .logOutItem(let viewModel):
            return viewModel.title.value ?? ""
        }
    }
}

extension SettingSectionItem: Equatable {
    static func == (lhs: SettingSectionItem, rhs: SettingSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension SettingSection: AnimatableSectionModelType, IdentifiableType {
    typealias Item = SettingSectionItem
    
    typealias Identity = String
    var identity: Identity { return title }
    
    var title: String {
        switch self {
        case .profile(let title, _): return title
        }
    }
    
    var items: [SettingSectionItem] {
        switch self {
        case .profile(_, let items): return items.map { $0 }
        }
    }
    
    init(original: SettingSection, items: [SettingSectionItem]) {
        switch original {
        case .profile(let title, let items): self = .profile(title: title, items: items)
        }
    }
}
