//
//  ProfileViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

import Firebase
import RxGesture
import RxSwift
import RxCocoa
import SnapKit

class ProfileViewController: ViewController {
    private let titleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.semanticContentAttribute = .forceRightToLeft
        
        return button
    }()
    private let editButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        
        return button
    }()
    private let groupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemBackground
        
        return imageView
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        
        return label
    }()
    private let memberCollectionView: UICollectionView = {
        let layout = UICollectionViewNestedCircleLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    private let memberCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        
        return label
    }()
    private let feeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        
        return label
    }()
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ProfileViewModel else { return }
        
        let viewWillAppear = rx.viewWillAppear
            .asObservable()
            .map { _ in }
        let tapMember = memberCollectionView.rx
            .tapGesture()
            .when(.recognized)
            .asObservable()
            .map { _ in }
        
        let output = viewModel.transform(
            input: ProfileViewModel.Input(
                viewWillAppear: viewWillAppear,
                tapMember: tapMember
            )
        )
        
        output.group
            .compactMap { $0?.name }
            .bind(to: self.rx.title)
            .disposed(by: self.disposeBag)
        
        output.title.bind(to: titleButton.rx.title(for: .normal)).disposed(by: disposeBag)
        output.groupImageURLString
            .compactMap { urlString in
                if let url = URL(string: urlString),
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    return image
                }
                
                return nil
            }
            .bind(to: groupImageView.rx.image)
            .disposed(by: disposeBag)
        output.message.bind(to: messageLabel.rx.text).disposed(by: disposeBag)
        output.members.bind(to: memberCollectionView.rx.items(cellIdentifier: ProfileMemberCell.cellIdentifier,
                                                              cellType: ProfileMemberCell.self))
        { index, element, cell in
            cell.bind(to: element)
        }
        .disposed(by: disposeBag)
        output.members.map { "\($0.count)명" }.bind(to: memberCountLabel.rx.text).disposed(by: disposeBag)
        output.fee.bind(to: feeLabel.rx.text).disposed(by: disposeBag)
        
        output.members.map { $0.count * 42 + 8 }
        .subscribe(on: MainScheduler.instance)
        .withUnretained(self)
        .subscribe(onNext: { own, width in
            own.memberCollectionView.snp.updateConstraints {
                $0.width.equalTo(width)
            }
        })
        .disposed(by: disposeBag)
        
        output.showMembers
            .withUnretained(self)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { own, profileMembersViewModel in
                let profileMembersViewController = ProfileMembersViewController()
                profileMembersViewController.viewModel = profileMembersViewModel
                
                own.navigationController?.pushViewController(profileMembersViewController,
                                                             animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        memberCollectionView.register(ProfileMemberCell.self,
                                      forCellWithReuseIdentifier: ProfileMemberCell.cellIdentifier)
        
        view.addSubview(titleButton)
        titleButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(editButton)
        editButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.width.height.equalTo(30)
        }
        
        view.addSubview(groupImageView)
        groupImageView.snp.makeConstraints {
            $0.top.equalTo(titleButton.snp.bottom).offset(80)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(150)
        }
        groupImageView.cornerRadius = 150 / 2
        
        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(groupImageView.snp.bottom).offset(45)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(memberCollectionView)
        memberCollectionView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(55)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(0)
            $0.height.equalTo(50)
        }
        
        let detailStackView = UIStackView(arrangedSubviews: [memberCountLabel, feeLabel])
        detailStackView.axis = .vertical
        detailStackView.distribution = .fill
        detailStackView.alignment = .fill
        detailStackView.spacing = 4
        view.addSubview(detailStackView)
        detailStackView.snp.makeConstraints {
            $0.top.equalTo(memberCollectionView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
}
