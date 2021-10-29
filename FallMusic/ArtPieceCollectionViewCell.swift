//
//  ArtPieceCollectionViewCell.swift
//  ArtPieceCollectionViewCell
//
//  Created by 俞佳兴 on 2021/10/7.
//

import UIKit

class ArtPieceCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArtPieceCollectionViewCell"
    
    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
//        let image = artPieces.compactMap { UIImage(named: $0.imageName) }
//        imageView.image = image.randomElement()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
