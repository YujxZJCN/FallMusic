//
//  SelectorView.swift
//  musefall
//
//  Created by Ziyi Lu on 2021/7/28.
//

import SwiftUI
import Photos
import ReplayKit

let shareIcons = [
    "wx", "qq", "dy", "pyq", "wb"
]
let shareIconNames = [
    "微信", "QQ", "抖音", "朋友圈", "微博"
]

struct SelectorView: View {
    var dismissAction: (() -> Void)
    var modelNames: [String]
    @Binding var isPlacementEnable: Bool
    @Binding var confirmedModel: String?
    @State var isRecording: Bool = false
    @State var endRecording: Bool = false
    @State var readyToShare: Bool = false
    @State var showShare: Bool = false
    
    var body: some View {
        if self.readyToShare {
            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("分享")
                        .foregroundColor(Color.white)
                        .fontWeight(Font.Weight.medium)
                    HStack(spacing: 30) {
                        ForEach(0 ..< shareIcons.count) {
                            index in
                            Button(action: {
                                // go back to Home
                                self.dismissAction()
                            }, label: {
                                VStack() {
                                    Image("\(shareIcons[index])")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 24, height: 24, alignment: .center)
                                        .clipped()
                                        .cornerRadius(8.0)
                                    Text(shareIconNames[index])
                                        .foregroundColor(Color.white)
                                }
                            })
                        }
                    }
                }
            }
            .padding(20)
            .background(self.isRecording ? Color.clear : Color.black.opacity(0.5))
            .alert(isPresented: $showShare) {
                Alert(title: Text("保存成功"), message: Text("请在手机相册中查看保存的视频"), dismissButton: .default(Text("确认") ))
            }
        } else if !self.endRecording {
            VStack(alignment: .center) {
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
        self.endRecording = true
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
                            }, completionHandler: { _, _ in
                                self.readyToShare = true
                                self.showShare = true
//                                self.alert(title: "保存成功", message: "请在相册中查看")
                            })
                        }
                    }
                }
            }
            
        }
    }
}
