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
import SCNRecorder

var sceneObserver: Cancellable!
let SHOW_AR_DEBUG = false

var playerLooper: AVPlayerLooper!
var queuePlayer: AVQueuePlayer!
var playerCurrentProgress: CMTime

let allModels = [
    "Plant": ["Plant_F_01", "Plant_F_02", "Plant_F_03"],
    "Cloud": ["Cloud_A_1",  "Cloud_A_2",  "Cloud_A_3" ],
    "Flower": ["Flower_A_6", "Flower_A_7", "Flower_A_8"],
    "Grass": ["Grass_A_01", "Grass_A_02", "Grass_A_03"]
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

// MARK: ARViewModel
class ARViewModel: ObservableObject {
    public var arView: ARView = ARView(frame: .zero)
    private var boxEntity: Entity
    private var currentModelName: String?
    
    init() {
        // Load box Model Entity
        let box = try! Experience.loadBox()
        boxEntity = box.steelBox!
        
        setupCoachingOverlay()
        setupARViewConfigure()
        
        // Add gestureRecognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        arView.addGestureRecognizer(gestureRecognizer)
        
        // Anchor for a horizontal plane for minimum 40cm * 40cm
        
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.4, 0.4])
        arView.scene.addAnchor(anchor)
        
        // Setup basic scene
        setupScene(anchor)
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
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
            print("<ARWorldTrackingConfiguration> meshWithClassification")
        } else if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
            print("<ARWorldTrackingConfiguration> mesh")
        }
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
            print("<ARWorldTrackingConfiguration> personSegmentationWithDepth")
        } else if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
            config.frameSemantics.insert(.personSegmentation)
            print("<ARWorldTrackingConfiguration> personSegmentation")
        }
        // Error: 'This set of frame semantics is not supported on this configuration'
//        if ARWorldTrackingConfiguration.supportsFrameSemantics(.bodyDetection) {
//            config.frameSemantics.insert(.bodyDetection)
//        }
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
            config.frameSemantics.insert(.smoothedSceneDepth)
        } else if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics.insert(.sceneDepth)
        }
        
        print(config.frameSemantics)
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
        print("DEBUG: Guesture Point Hit: \(point)")
        
        let results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .any)
        if let result = results.first {
            print("DEBUG: Raycast results[0]: \(result.worldTransform)")
            if (currentModelName != nil) {
                let filename = allModels[currentModelName!]![Int.random(in: 0...2)] + ".usdz"
                print("DEBUG: load filename \(filename)")
                
                let loadedModel = try!ModelEntity.load(named: filename)
                let model = loadedModel.children[0].children[0]
                let modelEntity = ModelEntity()
                modelEntity.addChild(model)
                model.setScale([0.001, 0.001, 0.001], relativeTo: .none)
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
                
                print("modelPhysicsEntity is Active: \(modelEntity.isActive)")
                print("modelEntity.components: \(modelEntity.components)")
                print("model.components: \(model.components)")
                
            }
        }
        
        
    }
    
    private func setupScene(_ anchor: AnchorEntity) {
        // Attach Occlusion Box
        let boxSize: Float = 1
        let boxMesh = MeshResource.generateBox(size: boxSize)
        let boxMaterial = OcclusionMaterial()
        let occlusionBox = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
        occlusionBox.position = [0, -0.5, 0]
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
        let playerItem = AVPlayerItem(URL: desURL)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        // Create a new player looper with the queue player and template item
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.play()

        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        queuePlayer.addPeriodicTimeObserver(forInterval: time, queue: .main) {
            [weak self] time in
            // update player transport UI
            playerCurrentProgress = time
        }
        
        return arViewModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = self.confirmModel {
            print("DEBUG: modelName \(modelName)")
            arViewModel.setCurrentModel(modelName)
//            DispatchQueue.main.async {
//                self.confirmModel = nil
//            }
        }
        if clearCurrentModel {
            print("DEBUG: Clear Current Model")
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
