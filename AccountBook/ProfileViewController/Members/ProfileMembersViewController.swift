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
    
    let isManager = BehaviorRelay<Bool>(value: false)
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ProfileMembersViewModel else { return }
        
        isManager
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isManager in
                guard let self = self else { return }
                
                self.navigationItem.rightBarButtonItems = isManager
                ? [self.addBarButton, self.searchBarButton]
                : [self.searchBarButton]
            })
            .disposed(by: disposeBag)
        
        let resetSearching = resetBarButton.rx.tap
            .withUnretained(self)
            .map { own, _ -> String? in
                own.navigationItem.rightBarButtonItems = own.isManager.value
                ? [own.addBarButton, own.searchBarButton]
                : [own.searchBarButton]
                
                return nil
            }
        let searching = searchBarButton.rx.tap
            .withUnretained(self)
            .flatMap { own, _ in own.showSearchAlert() }
        let searchMember = Observable.merge(resetSearching, searching)
        let inviteMembers = addBarButton.rx.tap
            .withUnretained(self)
            .flatMap { own, _ in own.showInviteAlert(title: "초대", message: nil) }
            .catch({ _ in .never() })
        
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
        
        output.isManager.bind(to: isManager).disposed(by: disposeBag)
        
        output.invite
            .withUnretained(self)
            .subscribe(onNext: { own, message in
                let activityVC = UIActivityViewController(activityItems: [message],
                                                          applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = own.view
                own.present(activityVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        output.failureInvitation
            .withUnretained(self)
            .flatMap { own, _ in own.showInviteAlert(title: "초대 실패", message: "잠시 후 다시 시도해주세요") }
            .subscribe(onNext: { print("초대장 생성 실패") })
            .disposed(by: disposeBag)
    }
    
    private func showSearchAlert() -> Single<String?> {
        return Single.create { [weak self] single in
            let alertController = UIAlertController(title: "검색", message: nil, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                guard let self = self else { return }
                
                if let text = alertController.textFields?.first?.text,
                   !text.isEmpty {
                    self.navigationItem.rightBarButtonItems = self.isManager.value
                    ? [self.addBarButton, self.searchBarButton, self.resetBarButton]
                    : [self.searchBarButton, self.resetBarButton]
                    
                    single(.success(alertController.textFields?.first?.text))
                } else {
                    single(.success(nil))
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                single(.success(nil))
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
    
    private func showInviteAlert(title: String?, message: String?) -> Single<Void> {
        return Single.create { [weak self] single in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                single(.success(()))
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
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
