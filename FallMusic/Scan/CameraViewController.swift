import UIKit
import AVFoundation
import Photos
import CoreImage
import Alamofire
import SwiftyJSON
import aubio
import SwiftUI

struct Peak {
    var position: Float
}

var desURL = ""
var peaks: [Peak] = []

class CameraViewController: UIViewController {
    @IBOutlet var musicStyleView: UIView!
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var scanView: UIView!
    
    @IBOutlet var styleButtons: [UIButton]! {
        didSet {
            for btn in styleButtons {
                btn.clipsToBounds = true
                btn.layer.cornerRadius = 8.0
            }
        }
    }
    
    let musicPlayURL = ""
    var currentMusicName = ""
    var currentMusicStyle = ""
    
    var musicRecommandURL: String {
        return "http://www.next.zju.edu.cn/yuyin/test/rec?name=\(file_name)&style="
    }
    var musicInfoURL: String {
        return "http://www.next.zju.edu.cn/yuyin/test/rec_res?name=\(file_name)"
    }
    var musicProcessURL: String {
        return "http://www.next.zju.edu.cn/yuyin/test/rec_pg?name=\(file_name)"
    }
    
    var musicLists: [String] = []
    
    lazy var musicURL: URL? = {
        var urlstring = "http://www.next.zju.edu.cn/yuyin/data/data/music/\(currentMusicStyle)/" + musicLists.first!
        urlstring = urlstring.replace(target: " ", withString: "%20")
        return URL(string: urlstring)
    }()
    
    @IBAction func popButtonTapped(_ sender: UIButton) {
        requestMusic(style: "pop")
        currentMusicStyle = "pop"
    }
    
    @IBAction func countryButtonTapped(_ sender: UIButton) {
        requestMusic(style: "country")
        currentMusicStyle = "country"
    }
    
    @IBAction func chinaButtonTapped(_ sender: UIButton) {
        requestMusic(style: "china")
        currentMusicStyle = "china"
    }
    
    @IBAction func jazzButtonTapped(_ sender: UIButton) {
        requestMusic(style: "jazz")
        currentMusicStyle = "jazz"
    }
    
    var musicReqTimer: Timer!
    
    let styleDic = ["china" : 6,
                    "country" : 10,
                    "jazz" : 14,
                    "pop" : 16
                ]
    
    func requestMusic(style: String) {
        if musicReqTimer != nil {
            musicReqTimer.invalidate()
        }
        self.musicLists.removeAll()
        print(musicRecommandURL + style)
        
        // Cloud
//        Alamofire.request(musicRecommandURL + style, method: .get).responseData { (response) in
//            self.musicReqTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.getMusicProcess), userInfo: nil, repeats: true)
//            self.musicReqTimer.fire()
//        }
        
        // Local
        useLocalMusic(with: style)
    }
    
    func useLocalMusic(with style: String) {
        let totalNum = styleDic[style]!
        let rndMusic = Int.random(in: 1...totalNum)
        let path = Bundle.main.path(forResource: style + String(rndMusic), ofType: "mp3")
        desURL = path!
        peaks = self.getPeaks(file: path!)
        DispatchQueue.main.async {
            let contentView = ContentView(dismissAction: {self.dismiss( animated: true, completion: {
                self.dismiss( animated: true, completion: nil)
            } )})
            let SwiftUIVC = UIHostingController(rootView: contentView)
            SwiftUIVC.modalPresentationStyle = .fullScreen
            self.present(SwiftUIVC, animated: true, completion: nil)
        }
    }
    
    
    @objc func getMusicProcess() {
        self.requestMusicProcess()
    }
    
    func requestMusicProcess() {
        Alamofire.request(musicProcessURL, method: .get).responseData { (response) in
            if let json = try? JSON(data: response.data!) {
                if let musicProcess = json["responseText"].string {
                    print(musicProcess)
                    if musicProcess == "100" {
                        self.musicReqTimer.invalidate()
                        sleep(1)
                        Alamofire.request(self.musicInfoURL, method: .get).responseData { (response) in
                            if let json = try? JSON(data: response.data!) {
                                print(json)
                                if let musicListsStr = json["responseText"].array {
                                    for list in musicListsStr {
                                        self.musicLists.append(list["name"].string ?? "")
                                    }
                                    
                                    self.downloadMusic(url: self.musicURL) { completed, destinationUrl  in
                                        
                                        // MARK: - music url and peak data
                                        print(destinationUrl!.path)
                                        print(self.getPeaks(file: destinationUrl!.relativeString.replace(target: "file://", withString: "")))
                                        desURL = destinationUrl!.path
                                        peaks = self.getPeaks(file: destinationUrl!.relativeString.replace(target: "file://", withString: ""))
                                        DispatchQueue.main.async {
                                            let contentView = ContentView(dismissAction: {self.dismiss( animated: true, completion: nil )})
                                            let SwiftUIVC = UIHostingController(rootView: contentView)
                                            SwiftUIVC.modalPresentationStyle = .fullScreen
                                            self.present(SwiftUIVC, animated: true, completion: nil)
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func downloadMusic(url: URL?, completionHandler: @escaping (_ success: Bool, _ destinationUrl: URL?) -> Void) {
        if let audioUrl = url {

            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                completionHandler(false, nil)
                // if the file doesn't exist
            } else {
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl) { location, response, error in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        completionHandler(true, destinationUrl)
                    } catch {
                        print(error)
                        completionHandler(false, nil)
                    }
                }.resume()
            }
        }
    }
    
    func getPeaks(file: String) -> [Peak] {
        let samplerate : uint_t = 44100
        let tempo = new_aubio_tempo("default", 1024, 512, samplerate)
        let samples = new_fvec(512)
        let source = new_aubio_source( file, 0, 512)
        let out = new_fvec(1)
        var read : uint_t = 0
        var total_frames : uint_t = 0
        var peaks = [Peak]()
        var lastBeatTime:Float?
        var bpms = [Float]()
        while true {
            aubio_source_do(source, samples, &read )
            aubio_tempo_do(tempo, samples, out)
            if (fvec_get_sample(out, 0) != 0) {
                let beat_time : Float = Float(total_frames) / Float(samplerate)
                peaks.append(Peak(position: beat_time))
                if lastBeatTime != nil {
                    let bpm = 60.0 / (beat_time-lastBeatTime!)
                    bpms.append(bpm)
                }
                lastBeatTime = beat_time
            }
            total_frames += read
            if (read < 512) {
                break
            }
        }
        print("Added \(peaks.count) peaks")
        var totalBpms:Float = 0
        for bpm in bpms {
            totalBpms += bpm
        }
        totalBpms /= Float(bpms.count)
//        print("Average bpm: \(round(totalBpms))")
        
        del_fvec(out)
        del_aubio_tempo(tempo)
        del_aubio_source(source)
        del_fvec(samples)
        
        return peaks
    }
    
    @IBOutlet var monitorView: UIImageView!
    
    let cameraManager = CameraManager()
    
    let filterManager = FilterManager.shared
    
    private lazy var filterView: UIView = {
        let monitorViewSize = self.monitorView.frame.size
        let frame = CGRect(x: 0, y: self.view.frame.height - 150, width: monitorViewSize.width, height: 150)
        
        let filterView = FilterCollection(frame: frame)
        return filterView
    }()
    
    var cameraRecorderStatus: CameraRecorder = .recorder {
        didSet {
//            if cameraRecorderStatus.isCamera {
//                captureButton.backgroundColor = .white
//            } else {
//                captureButton.backgroundColor = .red
//            }
        }
    }
    
    enum CameraRecorder: Int {
        case camera
        case recorder
        
        var isCamera: Bool {
            switch self {
            case .camera:
                return true
            default:
                return false
            }
        }
        
        mutating func toggle() {
            switch self {
            case .camera:
                self = .recorder
            default:
                self = .camera
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        cameraManager.videoSavingCompletion = { success in
            if success {
                self.alert(title: "扫描成功", message: "")
            } else {
                self.alert(title: "扫描失败", message: "")
            }
        }
        
        cameraManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        musicStyleView.transform = CGAffineTransform(translationX: 0, y: 200)
    }
    
    var timer: Timer!
    var firstTime = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
        scanView.alpha = 1.0
    }
    
    @objc func timerEvent() {
        if firstTime {
            cameraManager.controlRecording()
            firstTime.toggle()
        } else {
            cameraManager.controlRecording()
            firstTime.toggle()
            timer.invalidate()
        }
    }
    
    func setupUI() {
        
        cameraManager.filterImageCompletion = { image in
            let uiImage = image.convertToUIImage()
            
            DispatchQueue.main.async {
                self.monitorView.image = uiImage
            }
        }
        
        cameraManager.captureButtonCompletion = { isRecording in
            DispatchQueue.main.async {
//                self.captureButton.backgroundColor = isRecording ? .orange : .red
            }
        }
    }
    
//    // MARK: - switch input between photo and video
//    @IBAction func swtichCameraRecord(_ sender: UIButton) {
//        cameraRecorderStatus.toggle()
//        cameraManager.toggleCameraRecorderStatus()
//    }
//
    // MARK: - capture video or record video
//    @IBAction func capture(_ sender: UIButton) {
//
//        if cameraRecorderStatus.isCamera {
//            savePhoto()
//        } else {
//            cameraManager.controlRecording()
//        }
//    }
    
    func savePhoto() {
        guard let image = self.monitorView.image else {
            self.alert(title: "扫描成功", message: "")
            return
        }
        
        savePhotoLibrary(image: image)
    }
    
    
    func savePhotoLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }, completionHandler: { (success, error) in
                    if success {
                        self.alert(title: "扫描成功", message: "")
                    } else {
                        self.alert(title: "扫描失败", message: "")
                    }
                })
            }
        }
    }
    
    func alert(title: String, message: String) {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .default) { _ in
//                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}


extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension CameraViewController: VideoUploadAndProcessDoneProtocol {
    func uploadAndProcessDone() {
        DispatchQueue.main.async {
            self.scanView.removeFromSuperview()
            UIView.animate(withDuration: 0.5) {
                self.musicStyleView.transform = .identity
            } completion: { completed in
                return
            }
        }
    }
}

extension String{
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: .regularExpression, range: nil)
    }
}
