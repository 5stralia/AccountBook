//
//  ProfileMembersViewController.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/02/09.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class ProfileMembersViewController: ViewController {
    private let searchBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
    private let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private let resetBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
    private let collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = .init(leading: .fixed(0), top: .fixed(0), trailing: .fixed(0), bottom: .fixed(10))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(90))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ProfileMembersViewModel else { return }
        
        let resetSearching = resetBarButton.rx.tap
            .withUnretained(self)
            .map { own, _ -> String? in
                own.navigationItem.rightBarButtonItems = [
                    own.addBarButton,
                    own.searchBarButton
                ]
                
                return nil
            }
        let searching = searchBarButton.rx.tap
            .withUnretained(self)
            .flatMap { own, _ in own.showSearchAlert() }
        let searchMember = Observable.merge(resetSearching, searching)
        let inviteMembers = addBarButton.rx.tap.map { 1 }
        
        let output = viewModel.transform(input: ProfileMembersViewModel.Input(
            searchMember: searchMember,
            inviteMembers: inviteMembers
        ))
        
        output.items.asDriver()
            .drive(collectionView.rx.items(
                cellIdentifier: ProfileMembersCell.cellIdentifier,
                cellType: ProfileMembersCell.self
            )) { row, element, cell in
                cell.bind(to: element)
            }
            .disposed(by: disposeBag)
            
    }
    
    private func showSearchAlert() -> Observable<String?> {
        return Observable.create { [weak self] observer in
            let alertController = UIAlertController(title: "검색", message: nil, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                guard let self = self else { return }
                
                if let text = alertController.textFields?.first?.text,
                   !text.isEmpty {
                    self.navigationItem.rightBarButtonItems = [
                        self.addBarButton,
                        self.searchBarButton,
                        self.resetBarButton
                    ]
                    
                    observer.onNext(alertController.textFields?.first?.text)
                }
                
                observer.onCompleted()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                observer.onCompleted()
            }
            
            alertController.addTextField()
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self?.present(alertController, animated: true)
            
            return Disposables.create {
                alertController.dismiss(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        navigationItem.rightBarButtonItems = [
            addBarButton,
            searchBarButton
        ]
        
        view.backgroundColor = .systemBackground
        
        collectionView.register(
            ProfileMembersCell.self,
            forCellWithReuseIdentifier: ProfileMembersCell.cellIdentifier)
    }
    
    private func setUI() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
}
