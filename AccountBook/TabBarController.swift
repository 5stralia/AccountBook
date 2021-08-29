//
//  TabBarController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/25.
//

import UIKit

import Firebase

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: nil,
                                                        image: UIImage(systemName: "person"),
                                                        selectedImage: UIImage(systemName: "person.fill"))
        
        let chartViewController = ChartViewController()
        chartViewController.tabBarItem = UITabBarItem(title: nil,
                                                      image: UIImage(systemName: "chart.pie"),
                                                      selectedImage: UIImage(systemName: "chart.pie.fill"))
        
        let listViewController = ListViewController()
        let listNavigationController = UINavigationController(rootViewController: listViewController)
        listNavigationController.tabBarItem = UITabBarItem(title: nil,
                                                     image: UIImage(systemName: "note.text"),
                                                     selectedImage: UIImage(systemName: "note.text"))
        
        let settingViewController = SettingViewController()
        let settingViewModel = SettingViewModel()
        settingViewController.viewModel = settingViewModel
        settingViewController.tabBarItem = UITabBarItem(title: nil,
                                                        image: UIImage(systemName: "gearshape"),
                                                        selectedImage: UIImage(systemName: "gearshape.fill"))
        
        self.viewControllers = [profileViewController, chartViewController, listNavigationController, settingViewController]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            let signInViewController = SignInViewController()
            signInViewController.modalPresentationStyle = .fullScreen
            self.present(signInViewController, animated: true, completion: nil)
        }
    }

}
