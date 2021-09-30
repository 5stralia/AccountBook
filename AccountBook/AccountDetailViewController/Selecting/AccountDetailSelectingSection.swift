//
//  AccountDetailSelectingSection.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/30.
//

import RxDataSources

enum AccountDetailSelectingSection {
    case selecting(title: String, items:[AccountDetailSelectingSectionItem])
    case adding(title: String, items:[AccountDetailSelectingSectionItem])
}

enum AccountDetailSelectingSectionItem {
    case titleItem(viewModel: AccountDetailSelectingCellViewModel)
    case addingItem(viewModel: AccountDetailSelectingCellViewModel)
}

extension AccountDetailSelectingSectionItem: IdentifiableType {
    typealias Identity = String
    
    var identity: Identity {
        switch self {
        case .titleItem(let viewModel): return viewModel.title.value ?? ""
        case .addingItem(let viewModel): return viewModel.title.value ?? ""
        }
    }
}

extension AccountDetailSelectingSectionItem: Equatable {
    static func == (lhs: AccountDetailSelectingSectionItem, rhs: AccountDetailSelectingSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension AccountDetailSelectingSection: AnimatableSectionModelType, IdentifiableType {
    typealias Item = AccountDetailSelectingSectionItem
    
    typealias Identity = String
    var identity: Identity { return title }
    
    var title: String {
        switch self {
        case .selecting(let title, _): return title
        case .adding(let title, _): return title
        }
    }
    
    var items: [AccountDetailSelectingSectionItem] {
        switch self {
        case .selecting(_, let items): return items.map { $0 }
        case .adding(_, let items): return items.map { $0 }
        }
    }
    
    init(original: AccountDetailSelectingSection, items: [AccountDetailSelectingSectionItem]) {
        switch original {
        case .selecting(let title, let items): self = .selecting(title: title, items: items)
        case .adding(let title, let items): self = .adding(title: title, items: items)
        }
    }
}
