//
//  ArtPiece.swift
//  ArtPiece
//
//  Created by 俞佳兴 on 2021/10/7.
//

import Foundation

struct ArtPiece {
    var uuid: UUID!
    var imageName: String!
}

struct ExploreArtPiece {
    var uuid: UUID!
    var imageName: String
    var authorImageName: String
    var authorName: String
    var artPieceName: String
    
    init(imageName: String, artPieceName: String, authorImageName: String, authorName: String) {
        self.uuid = UUID.init()
        self.imageName = imageName
        self.artPieceName = artPieceName
        self.authorImageName = authorImageName
        self.authorName = authorName
    }
    
    static func allArtPieces() -> [ExploreArtPiece] {
        var artPieces: [ExploreArtPiece] = []
        artPieces.append(ExploreArtPiece(imageName: "Pic1", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic2", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic3", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic4", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic5", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic6", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic1", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic2", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic3", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic4", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic5", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic6", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic1", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic2", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic3", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic4", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic5", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic6", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic1", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic2", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic3", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic4", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic5", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(ExploreArtPiece(imageName: "Pic6", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        return artPieces
    }
    
}
