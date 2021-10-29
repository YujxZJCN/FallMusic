//
//  DataSource.swift
//  DataSource
//
//  Created by 俞佳兴 on 2021/10/7.
//

import Foundation
import UIKit

let artPieces: [ArtPiece] = [
    ArtPiece(uuid: UUID.init(), imageName: "artPiece0"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece1"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece2"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece3"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece4"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece5"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece6"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece7"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece8"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece9"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece10"),
    ArtPiece(uuid: UUID.init(), imageName: "artPiece11"),
]

let artPiecesImage = artPieces.compactMap { UIImage(named: $0.imageName) }
