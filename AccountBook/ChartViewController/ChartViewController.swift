//
//  ChartViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/25.
//

import UIKit

class ChartViewController: ViewController {
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
    
    override func bind(to viewModel: ViewModel) {
        guard let viewModel = viewModel as? ChartViewModel else { return }
        
        let output = viewModel.transform(input: ChartViewModel.Input())
        
        output.items.asDriver()
            .drive(onNext: { [weak self] subViews in
                guard let self = self else { return }
                
                var viewControllers: [ViewController] = []
                
                for subView in subViews {
                    switch subView {
                    case .pie(let viewModel):
                        let pieChartViewController = PieChartViewController()
                        pieChartViewController.viewModel = viewModel
                        
                        viewControllers.append(pieChartViewController)
                        
                    case .monthly(let viewModel):
                        let monthlyChartViewController = MonthlyChartViewController()
                        monthlyChartViewController.viewModel = viewModel
                        
                        viewControllers.append(monthlyChartViewController)
                        
                    case .adjustment(let viewModel):
                        let adjustmentChartViewController = AdjustmentChartViewController()
                        adjustmentChartViewController.viewModel = viewModel
                        
                        viewControllers.append(adjustmentChartViewController)
                    }
                }
                
                self.viewControllers = viewControllers
                
                self.pageViewController.setViewControllers([self.viewControllers.first!],
                                                           direction: .forward,
                                                           animated: false)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChild(self.pageViewController)
        self.pageContainer.addSubview(self.pageViewController.view)
        self.pageViewController.view.frame = self.pageContainer.bounds
        
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
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
