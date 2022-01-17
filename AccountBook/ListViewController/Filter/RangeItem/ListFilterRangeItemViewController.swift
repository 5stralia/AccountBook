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
        rangeSlider.backgroundColor = .clear
        rangeSlider.step = 100
        rangeSlider.enableStep = true
        
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
        
        let rangeContainer = UIView()
        rangeContainer.backgroundColor = .systemBackground
        rangeContainer.addSubview(self.rangeSlider)
        self.rangeSlider.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        }
        self.stackView.addArrangedSubview(rangeContainer)
        rangeContainer.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        
        self.stackView.addArrangedSubview(UIView())
    }
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ListFilterRangeItemViewModel else { return }
        
        let changeToASC = BehaviorRelay<Bool>(value: viewModel.isASC.value)
        self.ascButton.rx.tap.map { true }.bind(to: changeToASC).disposed(by: self.disposeBag)
        self.descButton.rx.tap.map { false }.bind(to: changeToASC).disposed(by: self.disposeBag)
        
        let changeMin = PublishRelay<Int>()
        let changeMax = PublishRelay<Int>()
        
        let output = viewModel.transform(input: ListFilterRangeItemViewModel.Input(
            changeToASC: changeToASC.asObservable(),
            changeMin: changeMin.asObservable(),
            changeMax: changeMax.asObservable()))
        
        output.isASC.map(!).bind(to: self.ascCheckImageView.rx.isHidden).disposed(by: self.disposeBag)
        output.isASC.bind(to: self.descCheckImageView.rx.isHidden).disposed(by: self.disposeBag)
        self.rangeSlider.minValue = Float(output.initialMin)
        self.rangeSlider.selectedMinimum = Float(output.initialMin)
        self.rangeSlider.maxValue = Float(output.initialMax)
        self.rangeSlider.selectedMaximum = Float(output.initialMax)
        
        self.rangeSlider.rx.min.compactMap { Int($0) }.bind(to: changeMin).disposed(by: self.disposeBag)
        self.rangeSlider.rx.max.compactMap { Int($0) }.bind(to: changeMax).disposed(by: self.disposeBag)
    }
}
