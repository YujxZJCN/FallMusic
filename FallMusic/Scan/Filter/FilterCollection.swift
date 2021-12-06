//
//  FilterCollection.swift
//  FullScreenCamera
//
//  Created by Jin on 2020/08/25.
//  Copyright © 2020 com.jinhyang. All rights reserved.
//

import UIKit

class FilterCollection: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let filterManager = FilterManager.shared
    
    private let xibName = "FilterCollection"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as? UIView else { return }
        view.frame = self.bounds
        self.addSubview(view)
        
        initCollectionView()
    }
    
    private func initCollectionView() {
        let nib = UINib(nibName: "FilterCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterName = filterManager.filterArr[indexPath.item].effectName
        filterManager.currentFilter = filterName
    }

}

extension FilterCollection: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterManager.filterArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell else {
            fatalError("can't dequeue FilterCollectionViewCell")
        }
        
        let filter = filterManager.filterArr[indexPath.item]
        
        cell.filterName.text = filter.filterName
        cell.filterImage.image = filter.image
        
        return cell
    }
}

extension FilterCollection: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 61
        let height = 134
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
