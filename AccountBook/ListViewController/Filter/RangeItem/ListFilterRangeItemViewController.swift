//
//  ListFilterRangeItemViewController.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/01/07.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import TTRangeSlider

class ListFilterRangeItemViewController: ViewController {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        return stackView
    }()
    private let ascButton: UIButton = {
        let button = UIButton()
        button.setTitle("오름차순", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemBackground
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        return button
    }()
    private let ascCheckImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.tintColor = .red
        imageView.isHidden = true
        
        return imageView
    }()
    private let descButton: UIButton = {
        let button = UIButton()
        button.setTitle("내림차순", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemBackground
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        return button
    }()
    private let descCheckImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.tintColor = .red
        imageView.isHidden = true
        
        return imageView
    }()
    private let rangeSlider: TTRangeSlider = {
        let rangeSlider = TTRangeSlider()
        rangeSlider.backgroundColor = .systemBackground
        
        return rangeSlider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemGray6

        self.view.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        
        let ascView = UIView()
        ascView.addSubview(self.ascButton)
        ascView.addSubview(self.ascCheckImageView)
        self.ascButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.ascCheckImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
        
        self.stackView.addArrangedSubview(ascView)
        ascView.snp.makeConstraints {
            $0.height.equalTo(44)
        }

        let descView = UIView()
        descView.addSubview(self.descButton)
        descView.addSubview(self.descCheckImageView)
        self.descButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.descCheckImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
        self.stackView.addArrangedSubview(descView)
        descView.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        let divider = UIView()
        divider.backgroundColor = .clear
        self.stackView.addArrangedSubview(divider)
        divider.snp.makeConstraints {
            $0.height.equalTo(100)
        }
        
        self.stackView.addArrangedSubview(self.rangeSlider)
        self.rangeSlider.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
        
        self.stackView.addArrangedSubview(UIView())
    }
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ListFilterRangeItemViewModel else { return }
        
        let isASC = BehaviorRelay<Bool>(value: true)
        self.ascButton.rx.tap.map { true }.bind(to: isASC).disposed(by: self.disposeBag)
        self.descButton.rx.tap.map { false }.bind(to: isASC).disposed(by: self.disposeBag)
        isASC.map(!).bind(to: self.ascCheckImageView.rx.isHidden).disposed(by: self.disposeBag)
        isASC.bind(to: self.descCheckImageView.rx.isHidden).disposed(by: self.disposeBag)
        
    }
}
