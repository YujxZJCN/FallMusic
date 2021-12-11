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
            VStack(alignment: .leading, spacing: 22){
                Text("AR场景美化")
                    .foregroundColor(Color.white)
                    .fontWeight(Font.Weight.medium)
                HStack(spacing: 22){
                    ForEach(0 ..< self.modelNames.count) {
                        index in
                        Button(action: {
                            self.isPlacementEnable = true
                            self.confirmedModel = self.modelNames[index]
                        }, label: {
                            VStack(){
                                Image("\(self.modelNames[index])")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 77, height: 77, alignment: .center)
                                    .clipped()
                                    .cornerRadius(8.0)
                                Text(self.modelNames[index])
                                    .foregroundColor(Color.white)
                                
                            }
                        })
                    }
                }
            }
            
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}
