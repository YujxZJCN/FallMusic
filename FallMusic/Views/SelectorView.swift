//
//  SelectorView.swift
//  musefall
//
//  Created by Ziyi Lu on 2021/7/28.
//

import SwiftUI
import Photos
import ReplayKit

struct SelectorView: View {
    
    var modelNames: [String]
    @Binding var isPlacementEnable: Bool
    @Binding var confirmedModel: String?
    @State var isRecording: Bool = false
    
    var body: some View {
        VStack(alignment: .center){
            if !self.isRecording {
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
            }
            
            if self.isRecording {
                Button(action: {
                    self.stopRecording()
                }, label: {
                    Image("recording")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48, alignment: .center)
                        .clipped()
                        .cornerRadius(24)
                })
            } else {
                Button(action: {
                    self.startRecording()
                }, label: {
                    Image("start")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48, alignment: .center)
                        .clipped()
                        .cornerRadius(24)
                })
            }
        }
        .padding(20)
        .background(self.isRecording ? Color.clear : Color.black.opacity(0.5))
    }
    
    func startRecording() {
        let recorder = RPScreenRecorder.shared()
        guard //录屏是否可用
            recorder.isAvailable &&
                //是否正在录屏
                !recorder.isRecording else { return }

        //录屏时是否启用麦克风。默认false
        recorder.isMicrophoneEnabled = true
        //录屏时是否启用摄像机。默认false
        recorder.isCameraEnabled = true
        //录屏启用摄像机时前后摄像头选择
        recorder.cameraPosition = .front
        self.isRecording = true
        print("=== start Recording ===")
        recorder.startRecording(handler: { error in
            if let error = error {
                print(error.localizedDescription)
//                self.showScreenRecordingAlert(message: error.localizedDescription)
            }
        })
    }
    func stopRecording() {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/\(UUID.init())video.mp4"
        let url = URL(fileURLWithPath: path)
        
        self.isRecording = false
//        let outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("newrecording")
//        let outputUrl = outputDirectory.appendingPathComponent("output.mp4")
        print("=== stop Recording ===")
        RPScreenRecorder.shared().stopRecording(withOutput: url) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    PHPhotoLibrary.requestAuthorization { status in
                        if status == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                            }, completionHandler: { _, _ in })
                        }
                    }
                }
            }
            
        }

    }
}
