//
//  ChartViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/25.
//

import UIKit

class ChartViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pageContainer: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    private var pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                          navigationOrientation: .horizontal)
    
    private var viewControllers: [UIViewController] = [] {
        didSet {
            self.pageControl.numberOfPages = self.viewControllers.count
        }
    }
    
    var viewModel: ChartViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChild(self.pageViewController)
        self.pageContainer.addSubview(self.pageViewController.view)
        self.pageViewController.view.frame = self.pageContainer.bounds
        
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        self.fooPageViewController()
    }

    func fooPageViewController() {
        let viewControllers: [UIViewController] = [UIColor.red, UIColor.black, UIColor.blue, UIColor.cyan].map {
            let viewController = UIViewController()
            viewController.view.backgroundColor = $0
            
            return viewController
        }
        
        self.viewControllers = viewControllers
        
        self.pageViewController.setViewControllers([self.viewControllers.first!],
                                                   direction: .forward,
                                                   animated: false)
        
    }
}

extension ChartViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.viewControllers.firstIndex(of: viewController) else { return nil }
        
        if index + 1 < self.viewControllers.count {
            return self.viewControllers[index + 1]
        } else {
            return self.viewControllers.first
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.viewControllers.firstIndex(of: viewController) else { return nil }
        
        if index - 1 >= 0 {
            return self.viewControllers[index - 1]
        } else {
            return self.viewControllers.last
        }
    }
    
}

extension ChartViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let viewController = pendingViewControllers.first,
           let index = self.viewControllers.firstIndex(of: viewController) {
            self.pageControl.currentPage = index
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed,
           let viewController = previousViewControllers.first,
           let index = self.viewControllers.firstIndex(of: viewController) {
            self.pageControl.currentPage = index
        }
    }
}
