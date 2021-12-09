//
//  ExploreViewController.swift
//  ExploreViewController
//
//  Created by 俞佳兴 on 2021/10/7.
//

import UIKit
import SwiftUI

class ExploreViewController: UIViewController {
    
    @IBOutlet var tabbar: UITabBarItem!
    @IBOutlet var menuButtons: [UIButton]!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBAction func menuButtonsTapped(_ sender: UIButton) {
        print(sender.tag)
        for btn in menuButtons {
            if btn.tag == sender.tag {
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            } else {
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            }
        }
    }
    
    var artPieces: [ExploreArtPiece] {
        return ExploreArtPiece.allArtPieces()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tab bar
        tabbar.title = "探索"
        tabbar.image = UIImage(named: "explore_unselect")
        tabbar.selectedImage = UIImage(named: "explore_select")
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.backgroundColor = .white
        self.tabBarController?.tabBar.inActiveTintColor()
        
        // collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
}

extension ExploreViewController: UICollectionViewDelegate,  UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        artPieces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreCollectionViewCell", for: indexPath) as! ExploreCollectionViewCell
        cell.imageView.image = UIImage(named: artPieces[indexPath.row].imageName)
        cell.captionLabel.text = artPieces[indexPath.row].artPieceName
        cell.authorImageView.image = UIImage(named: artPieces[indexPath.row].authorImageName)
        cell.authorLabel.text = artPieces[indexPath.row].authorName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
}

extension ExploreViewController: PinterestLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
            let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
//            print(itemSize)
            return itemSize * UIImage(named: artPieces[indexPath.row].imageName)!.size.height / UIImage(named: artPieces[indexPath.row].imageName)!.size.width + 58.0
        }
}
