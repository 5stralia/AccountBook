//
//  TabBarController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/25.
//

import UIKit

import Firebase
import RxSwift
import RxCocoa

class TabBarController: UITabBarController {
    
    var viewModel: TabBarViewModel? {
        willSet {
            if let viewModel = newValue {
                self.bind(to: viewModel)
            }
        }
    }
    
    var disposeBag = DisposeBag()
    
    private func bind(to viewModel: TabBarViewModel) {
        let output = viewModel.transform(input: TabBarViewModel.Input(
                                            viewWillAppear: self.rx.viewWillAppear.asObservable().map { _ in },
                                            viewWillDisappear: self.rx.viewWillDisappear.asObservable().map { _ in }))
        output.items.map { viewModels in
            return viewModels.compactMap { viewModel -> UIViewController? in
                switch viewModel {
                case let profileViewModel as ProfileViewModel:
                    let profileViewController = ProfileViewController()
                    profileViewController.viewModel = profileViewModel
                    let profileNavigationController = UINavigationController(rootViewController: profileViewController)
                    profileNavigationController.tabBarItem = UITabBarItem(title: nil,
                                                                    image: UIImage(systemName: "person"),
                                                                    selectedImage: UIImage(systemName: "person.fill"))
                    
                    return profileNavigationController
                    
                case let chartViewModel as ChartViewModel:
                    let chartViewController = ChartViewController()
                    chartViewController.viewModel = chartViewModel
                    chartViewController.tabBarItem = UITabBarItem(title: nil,
                                                                  image: UIImage(systemName: "chart.pie"),
                                                                  selectedImage: UIImage(systemName: "chart.pie.fill"))
                    
                    return chartViewController
                    
                case let listViewModel as ListViewModel:
                    let listViewController = ListViewController()
                    listViewController.viewModel = listViewModel
                    let listNavigationController = UINavigationController(rootViewController: listViewController)
                    listNavigationController.tabBarItem = UITabBarItem(title: nil,
                                                                 image: UIImage(systemName: "note.text"),
                                                                 selectedImage: UIImage(systemName: "note.text"))
                    
                    return listNavigationController
                    
                case let settingViewModel as SettingViewModel:
                    let settingViewController = SettingViewController()
                    settingViewController.viewModel = settingViewModel
                    settingViewController.tabBarItem = UITabBarItem(title: nil,
                                                                    image: UIImage(systemName: "gearshape"),
                                                                    selectedImage: UIImage(systemName: "gearshape.fill"))
                    
                    return settingViewController
                    
                case let signInViewModel as SignInViewModel:
                    let signInViewController = SignInViewController()
                    signInViewController.viewModel = signInViewModel
                    
                    return signInViewController
                    
                default:
                    return nil
                }
            }
        }
        .bind(to: self.rx.viewControllers)
        .disposed(by: self.disposeBag)
        
        output.items.map { $0.contains(where: { $0 is SignInViewModel }) }.asObservable()
            .bind(to: self.tabBar.rx.isHidden)
            .disposed(by: self.disposeBag)
    }

}
