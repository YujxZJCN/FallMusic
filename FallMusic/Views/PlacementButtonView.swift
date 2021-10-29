//
//  PlacementButtonView.swift
//  musefall
//
//  Created by Ziyi Lu on 2021/7/28.
//

import SwiftUI

struct PlacementButtonView: View {
    @Binding var isPlacementEnable: Bool
    @Binding var selectedModel: String?
    @Binding var confirmedModel: String?
    @Binding var clearCurrentModel: Bool
    
    var body: some View {
        HStack {
            // cancel button
            Button(action: {
                print("DEBUG: click placement button")
                self.isPlacementEnable = false
                self.selectedModel = nil
                self.clearCurrentModel = true
            }, label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
                
            })
            // confirm button
            Button(action: {
                print("DEBUG: click placement button")
                self.isPlacementEnable = false
                // self.confirmedModel = self.selectedModel
                self.selectedModel = nil
                self.clearCurrentModel = true
            }, label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
                
            })
        }
    }
}
