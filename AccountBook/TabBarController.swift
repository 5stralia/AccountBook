//
//  TabBarController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/25.
//

import UIKit

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
        listViewController.tabBarItem = UITabBarItem(title: nil,
                                                     image: UIImage(systemName: "note.text"),
                                                     selectedImage: UIImage(systemName: "note.text"))
        
        let settingViewController = SettingViewController()
        settingViewController.tabBarItem = UITabBarItem(title: nil,
                                                        image: UIImage(systemName: "gearshape"),
                                                        selectedImage: UIImage(systemName: "gearshape.fill"))
        
        self.viewControllers = [profileViewController, chartViewController, listViewController, settingViewController]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
