//
//  ExploreCollectionViewCell.swift
//  FallMusic
//
//  Created by 俞佳兴 on 2021/10/19.
//

import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {
    @IBOutlet var upperContentView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 4.0
        }
    }
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var authorImageView: UIImageView!
    @IBOutlet var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
    }
}
