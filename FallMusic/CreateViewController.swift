//
//  ViewController.swift
//  FallMusic
//
//  Created by 俞佳兴 on 2021/10/4.
//

import UIKit
import SwiftUI

var TABBARHIDDEN = false

class CreateViewController: UIViewController {
    
    @IBSegueAction func showContentView(_ coder: NSCoder) -> UIViewController? {
        let contentView = ContentView()
        return UIHostingController(coder: coder, rootView: contentView)
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.menuView.transform = .identity
            self.setTabBarHidden(true)
            TABBARHIDDEN = true
            self.view.addSubview(self.blurView)
            self.view.bringSubviewToFront(self.menuView)
            self.blurView.alpha = 1.0
        }) { (completed) in
        }
    }
    
    // menuView
    @IBOutlet var menuView: UIView!
    @IBOutlet var avatarView: UIImageView! {
        didSet {
            avatarView.clipsToBounds = true
            avatarView.layer.cornerRadius = 32
        }
    }
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailInfoLabel: UILabel!
    
    let transformLeft = CGAffineTransform(translationX: -280, y: 0)
    var blurView: UIView!
    
    // artPiecesView
    @IBOutlet var artPiecesView: UIView!
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    // tab bar
    @IBOutlet var tabbar: UITabBarItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // menuView
        blurView = UIView(frame: self.view.frame)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.4
        blurView.addSubview(blurEffectView)
        self.blurView.alpha = 0.0
        
        // artPiecesView
        collectionView.register(ArtPieceCollectionViewCell.self, forCellWithReuseIdentifier: ArtPieceCollectionViewCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        artPiecesView.addSubview(collectionView)
        
        // tab bar
        tabbar.title = "创作"
        tabbar.image = UIImage(named: "create_unselect")
        tabbar.selectedImage = UIImage(named: "create_select")
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.backgroundColor = .white
        self.tabBarController?.tabBar.inActiveTintColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        menuView.transform = transformLeft
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if TABBARHIDDEN && !self.menuView.frame.contains(touches.first!.location(in: menuView)) {
            UIView.animate(withDuration: 0.4, animations: {
                self.setTabBarHidden(false)
                TABBARHIDDEN = false
                self.blurView.alpha = 0.0
                self.menuView.transform = self.transformLeft
            }) { (completed) in
                self.blurView.removeFromSuperview()
            }
        }
    }
    
    
}

extension CreateViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = artPiecesView.bounds
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artPieces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtPieceCollectionViewCell.identifier, for: indexPath) as! ArtPieceCollectionViewCell
        cell.imageView.image = artPiecesImage[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: artPiecesView.frame.size.width / 3 - 3,
                      height: artPiecesView.frame.size.width / 3 - 3
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension UIViewController {
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool = true, duration: TimeInterval = 0.3) {
        if animated {
            if let frame = self.tabBarController?.tabBar.frame {
                let factor: CGFloat = hidden ? 1 : -1
                let y = frame.origin.y + (frame.size.height * factor)
                UIView.animate(withDuration: duration, animations: {
                    self.tabBarController?.tabBar.frame = CGRect(x: frame.origin.x, y: y, width: frame.width, height: frame.height)
                })
                return
            }
        }
        self.tabBarController?.tabBar.isHidden = hidden
    }
    
}

extension UITabBar{
    func inActiveTintColor() {
        if let items = items{
            for item in items{
                let selectedColor: UIColor = UIColor(red: 0.388, green: 0.632, blue: 0.717, alpha: 1)
                let unselectedColor: UIColor = UIColor(red: 0.749, green: 0.839, blue: 0.871, alpha: 1)
                
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedColor], for: .normal)
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor], for: .selected)
                UITabBar.appearance().unselectedItemTintColor = UIColor(red: 0.749, green: 0.839, blue: 0.871, alpha: 1)
            }
        }
    }
}
