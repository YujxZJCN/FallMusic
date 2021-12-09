//
//  Camera.swift
//  FullScreenCamera
//
//  Created by Jin on 2020/08/20.
//  Copyright © 2020 com.jinhyang. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation
import Photos
import Alamofire
import SwiftyJSON

var file_name = ""

protocol VideoUploadAndProcessDoneProtocol {
    func uploadAndProcessDone()
}

class CameraManager: NSObject {
    
    var delegate: VideoUploadAndProcessDoneProtocol?
    
    var videoDeviceDiscoverySession: AVCaptureDevice.DiscoverySession?
    
    let captureSession = AVCaptureSession()
    
    let sessionQueue = DispatchQueue(label: "session Queue")
    
    let audioQueue = DispatchQueue(label: "audio Queue")
    
    var assetWriter: AVAssetWriter?
    
    var assetVideoWriter: AVAssetWriterInput?
    
    var assetAudioWriter: AVAssetWriterInput?
    
    var assetAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    var videoDeviceInput: AVCaptureDeviceInput!
    
    var photoOutput = AVCapturePhotoOutput()
    
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    var audioDataOutput = AVCaptureAudioDataOutput()
    
    var filterImageCompletion: (CIImage) -> Void = { image in return }
    
    var captureButtonCompletion: (Bool) -> Void = { isRecording in return }
    
    var videoSavingCompletion: (Bool) -> Void = { didSave in return }
    
    let filterManager = FilterManager.shared
    
    var context = CIContext(options: nil)
    
    var isCamera: Bool = false
    
    var isWriting: Bool = false
    
    var startTime: CMTime? {
        didSet {
            isWriting = startTime == nil ? false : true
        }
    }
    
    var outputUrl: URL?
    
    var outputDirectory: URL?
    
    var videoSize: CGSize?
    
    override init() {
        super.init()
        
        videoDeviceDiscoverySession = .init(deviceTypes:  [.builtInDualCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera],
                                            mediaType: .video,
                                            position: .unspecified)
        
        setupSession()
        startSession()
    }
    
    func toggleCameraRecorderStatus() {
        isCamera.toggle()
    }
    
    
    // MARK: - control session
    func setupSession() {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            
            self.setupCameraSession()
            self.setupVideoSession()
            self.setupAudioSession()
            
            self.captureSession.commitConfiguration()
        }
    }
    
    func startSession(){
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession(){
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    
    // MARK: - set up session
    func setupCameraSession() {
        if self.captureSession.canAddOutput(self.photoOutput) {
            self.photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            self.captureSession.addOutput(self.photoOutput)
        }
    }
    
    func setupVideoSession() {
        do {
            guard let videoDeviceDiscoverySession = videoDeviceDiscoverySession,
                  let camera = videoDeviceDiscoverySession.devices.first else { return }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
            
            if self.captureSession.canAddInput(videoDeviceInput) {
                self.captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            }
            
            if self.captureSession.canAddOutput(self.videoDataOutput) {
                self.videoDataOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
                self.captureSession.addOutput(self.videoDataOutput)
            }
        } catch {
            return
        }
    }
    
    func setupAudioSession() {
        do {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if self.captureSession.canAddInput(audioDeviceInput) {
                self.captureSession.addInput(audioDeviceInput)
            }
            
            if self.captureSession.canAddOutput(self.audioDataOutput) {
                self.audioDataOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
                self.audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mp4)
                self.captureSession.addOutput(self.audioDataOutput)
            }
        } catch {
            return
        }
    }
    
    // MARK: - switchCamera
    func isSwitchingCamera() -> Bool {
        var successSwitching: Bool = false
        
        guard let videoDeviceDiscoverySession = videoDeviceDiscoverySession,
              videoDeviceDiscoverySession.devices.count > 1 else { return successSwitching }
        
        let currentVideoDevice = self.videoDeviceInput.device
        let currentPosition = currentVideoDevice.position
        let isFront = currentPosition == .front
        let preferredPosition: AVCaptureDevice.Position = isFront ? .back : .front
        let devices = videoDeviceDiscoverySession.devices
        let newVideoDevice: AVCaptureDevice? = devices.first(where: { device in
            return preferredPosition == device.position
        })
        
        if let newDevice = newVideoDevice {
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: newDevice)
                
                self.captureSession.beginConfiguration()
                self.captureSession.removeInput(self.videoDeviceInput)
                
                if self.captureSession.canAddInput(videoDeviceInput) {
                    self.captureSession.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    self.captureSession.commitConfiguration()
                }
                
                self.captureSession.commitConfiguration()
                successSwitching = true
                
            } catch let error {
                print("error occured while creating device input: \(error.localizedDescription)")
            }
        }
        
        return successSwitching
    }
    
    
    // MARK: - record video
    func configureAssetWrtier() {
        prepareVideoFile()
        
        do {
            assetWriter = try AVAssetWriter(url: URL.outputUrl, fileType: AVFileType.mp4)
            
            configureAssetVideoWriter()
            configureAssetAudioWriter()
            
            if let assetVideoWriter = assetVideoWriter {
                let adaptorSettings: [String: Any] = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32RGBA]
                assetAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetVideoWriter, sourcePixelBufferAttributes: adaptorSettings)
            }
            
        } catch {
            print("Unable to remove file at URL \(String(describing: outputUrl))")
        }
    }
    
    func configureAssetVideoWriter() {
        let videoSize = self.videoSize ?? CGSize(width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        
        let videoSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264,
                                            AVVideoWidthKey: videoSize.height,
                                           AVVideoHeightKey: videoSize.width,
                            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: videoSize.width * videoSize.height]
        ]
        
        assetVideoWriter = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        assetVideoWriter?.expectsMediaDataInRealTime = true
        
        assetVideoWriter = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        assetVideoWriter?.expectsMediaDataInRealTime = true
        
        guard let assetVideoWriter = assetVideoWriter else { return }
        assetWriter?.add(assetVideoWriter)
    }
    
    func configureAssetAudioWriter() {
        let audioSettings: [String: Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                    AVNumberOfChannelsKey: 2,
                                          AVSampleRateKey: 44100,
                                      AVEncoderBitRateKey: 192000]
        
        assetAudioWriter = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioSettings)
        assetAudioWriter?.expectsMediaDataInRealTime = true
        
        guard let assetAudioWriter = assetAudioWriter else { return }
        assetWriter?.add(assetAudioWriter)
    }
    
    
    func controlRecording() {
        
        if isWriting {
            stopRecording()
        }
        
        isWriting.toggle()
        captureButtonCompletion(isWriting)
    }
    
    func startRecording() {
        configureAssetWrtier()
        assetWriter?.startWriting()
    }
    
    func stopRecording() {
        guard startTime != nil else { return }
        
        sessionQueue.async {
            self.assetWriter?.finishWriting {
                self.startTime = nil
                self.saveVideo()
            }
        }
    }
    
    var uploadURL: String {
        return "http://www.next.zju.edu.cn/yuyin/upload/upload/?upload_project_name=\(file_name)&upload_type=web"
    }
    
    var processVideoURL: String {
        return "http://www.next.zju.edu.cn/yuyin/test/cmb?name=\(file_name)"
    }
    
    
    func saveVideo() {
        sessionQueue.async {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        guard let video = self.assetWriter?.outputURL else { return }
                        print(video)
                        
                        file_name = UUID.init().uuidString
                        
                        self.delegate?.uploadAndProcessDone()
//                        self.uploadVideo(withFileURL: video)
                        
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: video)
                    }, completionHandler: { (success, error) in
                        self.videoSavingCompletion(success)
                    })
                }
            }
        }
    }
    
    func uploadVideo(withFileURL url: URL) {
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data; boundary=----WebKitFormBoundary5JKKGtwMJrBZ6j93"
        ]
        Alamofire.upload(multipartFormData: { (formData) in
            let components = url.absoluteString.components(separatedBy: "/")
            let name = components.last!
            formData.append(url, withName: "file", fileName: name, mimeType: "video/MP4")
            
        }, usingThreshold: UInt64.init(), to: uploadURL, method: .post, headers: headers) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { (progress) in
//                    print(progress.fileTotalCount)
                }
                upload.responseJSON { (response) in
                    print(response)
                    self.processVideo()
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func processVideo() {
        print(processVideoURL)
        Alamofire.request(processVideoURL, method: .get).responseData { (response) in
            if let json = try? JSON(data: response.data!) {
                print(json)
                DispatchQueue.main.async {
                    self.delegate?.uploadAndProcessDone()
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoEditViewController") as! VideoEditViewController
//                    vc.modalPresentationStyle = .fullScreen
//                    vc.videoURL = "http://www.next.zju.edu.cn/yuyin/data/data/input_video/\(file_name).mp4"
//                    self.present(vc, animated: true, completion: nil)
//                    self.uploadedCount = 0
                }
            }
        }
    }
    
    func prepareVideoFile() {
        let ouputUrl = URL.outputUrl
        let outputDirectory = URL.outputDirectory
        
        if !FileManager.default.fileExists(atPath: outputDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Unable to create directory at URL \(outputDirectory)")
            }
        }
        
        if FileManager.default.fileExists(atPath: ouputUrl.path) {
            do {
                try FileManager.default.removeItem(at: ouputUrl)
            } catch {
                print("Unable to remove file at URL \(ouputUrl)")
            }
        }
    }
}


extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if output == videoDataOutput {
            writeVideoBuffer(output: output, sampleBuffer: sampleBuffer, connection: connection)
        } else {
            writeAudioBuffer(sampleBuffer: sampleBuffer)
        }
    }
    
    func writeVideoBuffer(output: AVCaptureOutput, sampleBuffer: CMSampleBuffer, connection: AVCaptureConnection) {
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait // 기본 orientation; [back: 90], [front: -90]
        }
        
        guard let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage: CIImage = getFilterImage(imageBuffer: imageBuffer)
        
        filterImageCompletion(ciImage)
        
        if !isCamera {
            guard isWriting else { return }
            
            if output == videoDataOutput {
                let timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                appendBuffer(pixelBuffer: ciImage.convertToCvPixelBuffer() ?? imageBuffer, timeStamp: timeStamp)
            }
        }
    }
    
    func writeAudioBuffer(sampleBuffer: CMSampleBuffer) {
        
        guard isWriting else { return }
        assetAudioWriter?.append(sampleBuffer)
    }
    
    func getFilterImage(imageBuffer: CVPixelBuffer) -> CIImage {
        
        var ciImage: CIImage = CIImage(cvPixelBuffer: imageBuffer)
        
        if let filterName = filterManager.currentFilter, let filter = CIFilter(name: filterName) {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            
            if let filteredImage = filter.outputImage {
                ciImage = filteredImage
            }
        }
        
        return ciImage
    }
    
    
    func appendBuffer(pixelBuffer: CVPixelBuffer, timeStamp: CMTime) {
        if startTime == nil {
            
            startRecording()
            startTime = timeStamp
            assetWriter?.startSession(atSourceTime: timeStamp)
        }
        
        assetAdaptor?.append(pixelBuffer, withPresentationTime: timeStamp)
    }
}

extension URL {
    static let outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording")
    
    static let outputUrl = outputDirectory.appendingPathComponent("test.mp4")
}


/** convert image type **/

extension CIImage {
    
    func convertToCGImage() -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(self, from: self.extent)
    }
    
    func convertToCvPixelBuffer() -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        let width: Int = Int(self.extent.width)
        let height: Int = Int(self.extent.height)
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32BGRA,
                            attrs,
                            &pixelBuffer)
        
        let context = CIContext()
        context.render(self, to: pixelBuffer!)
        
        return pixelBuffer
    }
    
    func convertToUIImage() -> UIImage {
        guard var cgImage = self.convertToCGImage() else { return UIImage() }
        
        let rect = CGRect(x: 0, y: cgImage.width/2 - cgImage.width/2, width: cgImage.width, height: cgImage.width)
        cgImage = cgImage.cropping(to:rect) ?? cgImage
        
        return UIImage(cgImage: cgImage)
    }
}
