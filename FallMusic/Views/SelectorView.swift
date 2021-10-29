//
//  SelectorView.swift
//  musefall
//
//  Created by Ziyi Lu on 2021/7/28.
//

import SwiftUI

struct SelectorView: View {
    
    var modelNames: [String]
    @Binding var isPlacementEnable: Bool
    @Binding var confirmedModel: String?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 30){
                ForEach(0 ..< self.modelNames.count) {
                    index in
                    Button(action: {
                        print("DEBUG: click model button \(self.modelNames[index])")
                        self.isPlacementEnable = true
                        self.confirmedModel = self.modelNames[index]
                    }, label: {
                        Text(self.modelNames[index])
                    })
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}
