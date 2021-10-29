//
//  PlaygroundPiece.swift
//  FallMusic
//
//  Created by 俞佳兴 on 2021/10/24.
//

import Foundation


struct PlaygroundPiece {
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
    
    static func allArtPieces() -> [PlaygroundPiece] {
        var artPieces: [PlaygroundPiece] = []
        artPieces.append(PlaygroundPiece(imageName: "Play1", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play2", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play3", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play4", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play5", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play6", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play1", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play2", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play3", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play4", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play5", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play6", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play1", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play2", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play3", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play4", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play5", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play6", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play1", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play2", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play3", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play4", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play5", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        artPieces.append(PlaygroundPiece(imageName: "Play6", artPieceName: "标题", authorImageName: "author", authorName: "作者"))
        return artPieces
    }
    
}
