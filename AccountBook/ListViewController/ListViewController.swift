//
//  ListViewController.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let infoCellIdentifier = "ListInfoCell"
    private let cellIdentifier = "ListAccountCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: self.infoCellIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: self.infoCellIdentifier)
        self.collectionView.register(UINib(nibName: self.cellIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: self.cellIdentifier)
        
        self.setNavigationItems()
    }
    
    private func setNavigationItems() {
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
                                           style: .plain,
                                           target: self,
                                           action: nil)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addAccount))
        let monthlyButton = UIBarButtonItem(title: "월별", style: .plain, target: self, action: nil)
        
        self.navigationItem.rightBarButtonItems = [addButton, monthlyButton, filterButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    @objc private func addAccount() {
        let accountDetailViewController = AccountDetailViewController()
        let navigationController = UINavigationController(rootViewController: accountDetailViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.bounds.width, height: 122)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }
}

extension ListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 50
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.infoCellIdentifier, for: indexPath) as! ListInfoCell
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! ListAccountCell
            
            return cell
        }
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
