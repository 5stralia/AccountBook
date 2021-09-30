//
//  AccountDetailSection.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/28.
//

import Foundation

import RxDataSources

enum AccountDetailSection {
    case main(title: String, items: [AccountDetailSectionItem])
    case sub(title: String, items: [AccountDetailSectionItem])
}

enum AccountDetailSectionItem {
    case titleItem(viewModel: TextFieldCellViewModel)
    case amountItem(viewModel: TextFieldCellViewModel)
    case categoryItem(viewModel: AccountDetailSelectionCellViewModel)
    case payerItem(viewModel: AccountDetailSelectionCellViewModel)
    case participantItem(viewModel: AccountDetailSelectionCellViewModel)
    case dateItem(viewModel: AccountDetailDateCellViewModel)
    case segmentItem(viewModel: AccountDetailSegmentCellViewModel)
}

extension AccountDetailSectionItem: IdentifiableType {
    typealias Identity = String
    
    var identity: Identity {
        switch self {
        case .titleItem(let viewModel):
            return viewModel.placeholderText.value ?? ""
        case .amountItem(let viewModel):
            return viewModel.placeholderText.value ?? ""
        case .categoryItem(let viewModel):
            return viewModel.title.value ?? ""
        case .payerItem(let viewModel):
            return viewModel.title.value ?? ""
        case .participantItem(let viewModel):
            return viewModel.title.value ?? ""
        case .dateItem(let viewModel):
            return viewModel.title.value ?? ""
        case .segmentItem:
            return "date_segment"
        }
    }
}

extension AccountDetailSectionItem: Equatable {
    static func == (lhs: AccountDetailSectionItem, rhs: AccountDetailSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension AccountDetailSection: AnimatableSectionModelType, IdentifiableType {
    typealias Item = AccountDetailSectionItem
    
    typealias Identity = String
    var identity: Identity { return title }
    
    var title: String {
        switch self {
        case .main(let title, _):
            return title
        case .sub(let title, _):
            return title
        }
    }
    
    var items: [AccountDetailSectionItem] {
        switch self {
        case .main(_, let items):
            return items.map { $0 }
        case .sub(_, let items):
            return items.map { $0 }
        }
    }
    
    init(original: AccountDetailSection, items: [AccountDetailSectionItem]) {
        switch original {
        case .main(let title, let items): self = .main(title: title, items: items)
        case .sub(let title, let items): self = .sub(title: title, items: items)
        }
    }
}
