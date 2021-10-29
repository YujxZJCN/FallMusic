//
//  PlaygroundViewController.swift
//  FallMusic
//
//  Created by 俞佳兴 on 2021/10/23.
//

import UIKit

class PlaygroundViewController: UIViewController {
    @IBOutlet var tabbar: UITabBarItem!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var menuButtons: [UIButton]!
    
    var artPieces: [PlaygroundPiece] {
        return PlaygroundPiece.allArtPieces()
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        print(sender.tag)
        for btn in menuButtons {
            if btn.tag == sender.tag {
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            } else {
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // tab bar
        tabbar.title = "广场"
        tabbar.image = UIImage(named: "playground_unselect")
        tabbar.selectedImage = UIImage(named: "playground_select")
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

extension PlaygroundViewController: UICollectionViewDelegate,  UICollectionViewDataSource {
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

extension PlaygroundViewController: PinterestLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
            let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
            print(itemSize)
            return itemSize * UIImage(named: artPieces[indexPath.row].imageName)!.size.height / UIImage(named: artPieces[indexPath.row].imageName)!.size.width + 58.0
        }
}

