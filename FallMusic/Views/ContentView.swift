//
//  ContentView.swift
//  musefall
//
//  Created by Ziyi Lu on 2021/7/25.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var dismissAction: (() -> Void)
    @StateObject var arViewModel = ARViewModel()
    @State private var isPlacementEnable: Bool = false
    @State private var selectedModel: String?
    @State private var confirmModel: String?
    @State private var clearCurrentModel: Bool = false
    
    var modelNames: [String] = [
        "plant", "cloud", "flower", "grass", "item", "gem", "planet"
    ]
//
//    init() {
//        // Just play the audio here
//        audioViewModel.playOrPause()
//    }
    
    var body: some View {
        Color.black
            .ignoresSafeArea(.all) // Ignore just for the color
            .overlay(
                ZStack(alignment: .bottom){
                    ARViewContainer(arViewModel: arViewModel, confirmModel: self.$confirmModel, clearCurrentModel: self.$clearCurrentModel)
                    
                    if self.isPlacementEnable {
                        PlacementButtonView(isPlacementEnable: self.$isPlacementEnable, selectedModel: self.$selectedModel, confirmedModel: self.$confirmModel, clearCurrentModel: self.$clearCurrentModel)
                    } else {
                        SelectorView(dismissAction: self.dismissAction, modelNames: self.modelNames, isPlacementEnable: self.$isPlacementEnable, confirmedModel: self.$confirmModel)
                    }
                }
            )
    }
}
