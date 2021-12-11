//
//  ARViewModel.swift
//  musefall
//
//  Created by Ziyi Lu on 2021/7/25.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit
import Combine

var sceneObserver: Cancellable!
let SHOW_AR_DEBUG = false

var audioPlayer: AVAudioPlayer!
var musicProgress = 0.0

//var playerLooper: AVPlayerLooper!
//var queuePlayer: AVQueuePlayer!
//var playerCurrentProgress: CMTime!

var audioViewModel: AudioViewModel = AudioViewModel("china1", withExtension: "mp3")

let allModels = [
    "plant": ["Plant_F_01", "Plant_F_02", "Plant_F_03"],
    "cloud": ["Cloud_A_1",  "Cloud_A_2",  "Cloud_A_3" ],
    "flower": ["Flower_A_6", "Flower_A_7", "Flower_A_8"],
    "grass": ["Grass_A_01", "Grass_A_02", "Grass_A_03"],
    "gem": [
        "Diamond-Blue-Specular", "Diamond-Cyan-Specular", "Diamond-Green-Specular",
        "Diamond-Peach-Specular", "Diamond-Pink-Specular", "Diamond-Yellow-Specular",
        "Dodeca-Blue-Specular", "Dodeca-Cyan-Specular", "Dodeca-Green-Specular",
        "Dodeca-Peach-Specular", "Dodeca-Pink-Specular", "Dodeca-Yellow-Specular",
        "Icosa-Blue-Specular", "Icosa-Cyan-Specular", "Icosa-Green-Specular",
        "Icosa-Peach-Specular", "Icosa-Pink-Specular", "Icosa-Yellow-Specular",
        "Octa-01-Blue-Specular", "Octa-01-Cyan-Specular", "Octa-01-Green-Specular",
        "Octa-01-Peach-Specular", "Octa-01-Pink-Specular", "Octa-01-Yellow-Specular",
        "Octa-02-Blue-Specular", "Octa-02-Cyan-Specular", "Octa-02-Green-Specular",
        "Octa-02-Peach-Specular", "Octa-02-Pink-Specular", "Octa-02-Yellow-Specular",
        "Radiant-Blue-Specular", "Radiant-Cyan-Specular", "Radiant-Green-Specular",
        "Radiant-Peach-Specular", "Radiant-Pink-Specular", "Radiant-Yellow-Specular"
    ],
    "item": [
        "Items_EnergyCan_01",
        "Items_Coin_02",
        "Items_Banana_01",
        "Items_Burger_01",
        "Items_CoffeeCup_02",
        "Items_Wrench_01",
        "Items_Beer_01",
        "Items_Donut_01",
        "Items_Hammer_01",
        "Items_IceBlock_03",
        "Items_Plunger_01",
        "Items_Cash_01",
        "Items_ChocolateBar_02",
        "Items_MilkCarton_02",
        "Items_HotDog_01",
        "Items_FryPan_02",
        "Items_Apple_01",
        "Items_SmartPhone_08",
        "Items_Donut_03",
        "Items_FryPan_01",
        "Items_Taco_01",
        "Items_Cookie_01",
        "Items_Cash_02",
        "Items_IceBlock_01",
        "Items_Spatula_01",
        "Items_Cash_03",
        "Items_Donut_02",
        "Items_SodaCan_03",
        "Items_Sandwich_01",
        "Items_WalkieTalkie_02",
        "Items_CupCake_03",
        "Items_PopCorn_01",
        "Items_SmartPhone_01",
        "Items_Spanner_01",
        "Items_Cake_01",
        "Items_PlasticCoffeeCup_02",
        "Items_Coin_01",
        "Items_StrawCup_02"
    ],
    "planet": [
        "Earth", "Jupiter", "Mars", "Mercury", "Moon",
        "Neptune", "Pluto", "Saturn", "Sun"
    ]
]

let modelScaleAndTranslation = [
    "plant":   [SIMD3<Float>(x: 0.005, y: 0.005, z: 0.005), SIMD3<Float>(x: 0, y: 0, z: 0)],
    "cloud":   [SIMD3<Float>(x: 0.001, y: 0.001, z: 0.001), SIMD3<Float>(x: 0, y: 0, z: 0.01)],
    "flower":  [SIMD3<Float>(x: 0.005, y: 0.005, z: 0.005), SIMD3<Float>(x: 0, y: 0, z: 0)],
    "grass":   [SIMD3<Float>(x: 0.003, y: 0.003, z: 0.003), SIMD3<Float>(x: 0, y: 0, z: 0)],
    "gem":     [SIMD3<Float>(x: 0.002, y: 0.002, z: 0.002), SIMD3<Float>(x: 0, y: 0, z: 0.001)],
    "item":    [SIMD3<Float>(x: 0.003, y: 0.003, z: 0.003), SIMD3<Float>(x: 0, y: 0, z: 0)],
    "planet":  [SIMD3<Float>(x: 0.01, y: 0.01, z: 0.01), SIMD3<Float>(x: 0, y: 0, z: 0)]
]

class AREntity: Entity, HasCollision, HasModel {
    required init() {
        super.init()
//        self.model = ModelComponent(mesh: .generateBox(size: [1,0.2,1]), materials: [SimpleMaterial(color: .lightGray, roughness: 1.0, isMetallic: true)])
        let loadModel = try!ModelEntity.load(named: "Plant_F_02.usdz")
        self.model = loadModel.components[ModelComponent.self]
        self.generateCollisionShapes(recursive: true)
        self.scale = [0.1, 0.1, 0.1]
    }
}

var globalTimer: Timer!

// MARK: ARViewModel
class ARViewModel: ObservableObject {
    public var arView: ARView = ARView(frame: .zero)
//    private var boxEntity: Entity
    private var currentModelName: String?

    init() {
        // Load box Model Entity
//        let box = try! Experience.loadBox()
//        boxEntity = box.steelBox!
        
        setupCoachingOverlay()
        setupARViewConfigure()
        
        // Add gestureRecognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        arView.addGestureRecognizer(gestureRecognizer)
        
        // Anchor for a horizontal plane for minimum 40cm * 40cm
        
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [2.0, 2.0])
        arView.scene.addAnchor(anchor)
        
        // Setup basic scene
        setupScene(anchor)
        
        globalTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: desURL))
        audioPlayer.prepareToPlay()
    }
    
    @objc func updateTimer() {
        musicProgress += 0.1
    }
    
    // MARK: Private Functions
    
    private func setupCoachingOverlay() {
        // Configure coachingOverlay
        let coachingOverlay = ARCoachingOverlayView(frame: arView.frame)
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        // add overlay to arView hierarchy
        arView.addSubview(coachingOverlay)
        // set layout constraints
        coachingOverlay.topAnchor.constraint(equalTo: arView.topAnchor).isActive = true
        coachingOverlay.leadingAnchor.constraint(equalTo: arView.leadingAnchor).isActive = true
        coachingOverlay.trailingAnchor.constraint(equalTo: arView.trailingAnchor).isActive = true
        coachingOverlay.bottomAnchor.constraint(equalTo: arView.bottomAnchor).isActive = true
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = arView.session
    }
    
    // MARK: AR Configure
    private func setupARViewConfigure() {
        // Configure arView
        let config = ARWorldTrackingConfiguration()
        // Auto Focus
        config.isAutoFocusEnabled = true
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
//        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
//            config.sceneReconstruction = .meshWithClassification
//            print("<ARWorldTrackingConfiguration> meshWithClassification")
//        }
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
            print("<ARWorldTrackingConfiguration> mesh")
        }
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
            print("<ARWorldTrackingConfiguration> personSegmentationWithDepth")
        }
//        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
//            config.frameSemantics.insert(.personSegmentation)
//            print("<ARWorldTrackingConfiguration> personSegmentation")
//        }
        // Error: 'This set of frame semantics is not supported on this configuration'
//        if ARWorldTrackingConfiguration.supportsFrameSemantics(.bodyDetection) {
//            config.frameSemantics.insert(.bodyDetection)
//        }
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
            config.frameSemantics.insert(.smoothedSceneDepth)
        }
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics.insert(.sceneDepth)
        }
        arView.session.run(config)
                
        // MARK: Debug Options
        if SHOW_AR_DEBUG {
            arView.debugOptions.insert(.showAnchorGeometry)
            arView.debugOptions.insert(.showAnchorOrigins)
            arView.debugOptions.insert(.showFeaturePoints)
            arView.debugOptions.insert(.showPhysics)
            arView.debugOptions.insert(.showSceneUnderstanding)
            arView.debugOptions.insert(.showStatistics)
            arView.debugOptions.insert(.showWorldOrigin)
        }
    }
    
    // MARK: Tapped
    @objc func tapped(gesture: UITapGestureRecognizer) {
        // Get Hit Position
        let point = gesture.location(in: arView)
//        print("DEBUG: Guesture Point Hit: \(point)")
        
        let results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .any)
        if let result = results.first {
//            print("DEBUG: Raycast results[0]: \(result.worldTransform)")
            if (currentModelName != nil) {
                let modelCount = allModels[currentModelName!]!.count
                let filename = allModels[currentModelName!]![Int.random(in: 0...modelCount-1)] + ".usdz"
//                print("DEBUG: load filename \(filename)")
                
                let loadedModel = try!ModelEntity.load(named: filename)
                let model = loadedModel.children[0].children[0]
                let modelEntity = ModelEntity()
                modelEntity.addChild(model)
                let modelScale = modelScaleAndTranslation[currentModelName!]![0]
                let modelTranslation = modelScaleAndTranslation[currentModelName!]![1]
                model.setScale(modelScale, relativeTo: .none)
                model.setPosition(modelTranslation, relativeTo: .none)
                modelEntity.generateCollisionShapes(recursive: true)
                
//                let modelPhysicsEntity = modelEntity as (Entity & HasPhysics)
//                let physics = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
////                let motion: PhysicsMotionComponent = .init(linearVelocity: [0.1 ,0, 0], angularVelocity: [3, 3, 3])
//                let usdzEntity = modelEntity.findEntity(named: filename)
//                usdzEntity?.components.set(physics)
//                model.children[0].components.set(motion)
                
//                if let collisionComponent = model.components[CollisionComponent.self] as? CollisionComponent {
//                    print("has collision component \(collisionComponent.shapes)")
//                    model.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 1, material: nil, mode: .dynamic)
//                    model.components[PhysicsMotionComponent.self] = PhysicsMotionComponent(linearVelocity: [0, 5, 0], angularVelocity: [0, 5, 0])
//                }
                
                let anchorEntity = AnchorEntity(world: result.worldTransform)
                anchorEntity.addChild(modelEntity)
                
                arView.scene.addAnchor(anchorEntity)
                // Install Gesture for modelEntity
                arView.installGestures(.all, for: modelEntity)
                
//                print("modelPhysicsEntity is Active: \(modelEntity.isActive)")
//                print("modelEntity.components: \(modelEntity.components)")
//                print("model.components: \(model.components)")
                
            }
        }
        
        
    }
    
    private func setupScene(_ anchor: AnchorEntity) {
        // Attach Occlusion Box
        let boxSize: Float = 50.0
        let boxMesh = MeshResource.generateBox(size: boxSize)
        let boxMaterial = OcclusionMaterial()
        let occlusionBox = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
        occlusionBox.position = [0, -25.0, 0]
        anchor.addChild(occlusionBox)
    }
    
    // MARK: Public Functions
    
    public func setCurrentModel(_ modelName: String) {
        currentModelName = modelName
    }
    
    public func clearCurrentModel() {
        currentModelName = nil
    }
}

// MARK: ARViewContainer
struct ARViewContainer: UIViewRepresentable {
    
    
    public let arViewModel: ARViewModel
    @Binding var confirmModel: String?
    @Binding var clearCurrentModel: Bool
    
    // Handling audio playing and tuning
//    private var audioViewModel: AudioViewModel = AudioViewModel("song", withExtension: "wav")
    
    func makeUIView(context: Context) -> ARView {
//        MARK: Body Tracking
//        Uncomment the floowing codes to enable body tracking function
        arViewModel.arView.setupForBodyTracking()
        arViewModel.arView.scene.addAnchor(bodySkeletonAnchor)
        sceneObserver = arViewModel.arView.scene.subscribe(to: SceneEvents.Update.self) {
            _ in self.updateScene()
        }

        // MARK: Play BGM
        print("<DEBUG> AVPlayerItem url: \(desURL)")
//        let name = desURL.components(separatedBy: "/").last!.components(separatedBy: ".mp3")[0]
//        print("<DEBUG> Audio Name: \(name)")
//        audioViewModel = AudioViewModel(name, withExtension: "mp3")
//        audioViewModel.playOrPause()
        
//        let playerItem = AVPlayerItem(url: URL(string: desURL)!)
//        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        // Create a new player looper with the queue player and template item
//        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
//        queuePlayer.play()

        // Notify every half second
//        let timeScale = CMTimeScale(NSEC_PER_SEC)
//        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
//        queuePlayer.addPeriodicTimeObserver(forInterval: time, queue: .main) {
//            time in
//             update player transport UI
//            playerCurrentProgress = time
//        }
        
        return arViewModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = self.confirmModel {
//            print("DEBUG: modelName \(modelName)")
            arViewModel.setCurrentModel(modelName)
//            DispatchQueue.main.async {
//                self.confirmModel = nil
//            }
        }
        if clearCurrentModel {
//            print("DEBUG: Clear Current Model")
            DispatchQueue.main.async {
                self.clearCurrentModel = false
            }
            arViewModel.clearCurrentModel()
        }
    }
    
    // MARK: Scene update
    func updateScene() {
        bodySkeleton?.tick()
    }
}
