//
//  UICollectionViewNestedCircleLayout.swift
//  AccountBook
//
//  Created by Hoju Choi on 2022/02/04.
//

import UIKit

final class UICollectionViewNestedCircleLayout: UICollectionViewLayout {
    
    var contentBounds = CGRect.zero
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    var itemSize: CGSize = .zero
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        
        let count = collectionView.numberOfItems(inSection: 0)
        
        var currentIndex = 0
        var lastFrame: CGRect = .zero
        
        let cvWidth = collectionView.bounds.width
        let nestedLength: CGFloat = 8
        
        while currentIndex < count {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentIndex,
                                                                                     section: 0))
            
            let rect = CGRect(x: lastFrame.maxX > 0 ? lastFrame.maxX - nestedLength : 0,
                              y: lastFrame.minY,
                              width: itemSize.width,
                              height: itemSize.height)
            
            attributes.frame = rect
            
            cachedAttributes.append(attributes)
            contentBounds = contentBounds.union(lastFrame)
            
            currentIndex += 1
            lastFrame = rect
        }
        
    }
    
    override var collectionViewContentSize: CGSize { return contentBounds.size }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        guard let lastIndex = cachedAttributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex)
        else { return attributesArray }
        
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        
        return attributesArray
    }
    
    // Perform a binary search on the cached attributes array.
    func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }

}
