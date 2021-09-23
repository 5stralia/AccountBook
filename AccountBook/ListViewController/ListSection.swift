//
//  ListSection.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/22.
//

import Foundation

import RxDataSources

enum ListSection {
    case info(title: String, items: [ListSectionItem])
    case account(title: String, items: [ListSectionItem])
}

enum ListSectionItem {
    case infoItem(viewModel: ListInfoCellViewModel)
    case accountItem(viewModel: ListAccountCellViewModel)
}

extension ListSectionItem: IdentifiableType {
    typealias Identity = String
    
    var identity: Identity {
        switch self {
        case .infoItem:
            return "info"
        case .accountItem(let viewModel):
            return (viewModel.date.value ?? "")
            + (viewModel.category.value ?? "")
            + (viewModel.title.value ?? "")
            + (viewModel.amount.value ?? "")
        }
    }
}

extension ListSectionItem: Equatable {
    static func == (lhs: ListSectionItem, rhs: ListSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension ListSection: AnimatableSectionModelType, IdentifiableType {
    typealias Item = ListSectionItem
    
    typealias Identity = String
    var identity: Identity { return title }
    
    var title: String {
        switch self {
        case .info(let title, _): return title
        case .account(let title, _): return title
        }
    }
    
    var items: [ListSectionItem] {
        switch self {
        case .info(_, let items): return items
        case .account(_, let items): return items
        }
    }
    
    init(original: ListSection, items: [ListSectionItem]) {
        switch original {
        case .info(let title, let items): self = .info(title: title, items: items)
        case .account(let title, let items): self = .account(title: title, items: items)
        }
    }
}
