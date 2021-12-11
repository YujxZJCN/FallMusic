//
//  BodySkeleton.swift
//  musefall
//
//  Created by Ziyi Lu on 2021/9/21.
//

import Foundation
import ARKit
import RealityKit
import SwiftUI

public var bodySkeleton: BodySkeleton?
public var bodySkeletonAnchor = AnchorEntity()
public var peakSet: Set<Float> = Set<Float>()

let audioFactory = AudioFactory()

public class AudioFactory {
    var players: [AVAudioPlayer] = []
    
    init() {
        let soundUrl = Bundle.main.path(forResource: "dingsound", ofType: "wav")
        for _ in 1...20 {
            let soundEffectPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundUrl!))
            soundEffectPlayer.prepareToPlay()
            soundEffectPlayer.volume = 1.0
            players.append(
                soundEffectPlayer
            )
        }
    }
    
    func play() {
        for player in players {
            if !player.isPlaying {
                print("<Fac> Play Success")
                player.play()
                return
            }
        }
        print("<Fac> Play Failed")
    }
}

public struct EffectEntity {
    var anchor: AnchorEntity
    var attachedTime: Int
    var lifeTime: Float
    
    func tick() -> Bool {
        let timeStamp = Int(Date().timeIntervalSince1970)
        if timeStamp - attachedTime >= Int(lifeTime * 1000) {
            // TOFIX: whether truly remove entity from scene
            anchor.removeFromParent()
            // arView.scene.remove(anchor)
            return false
        }
        return true
    }
}

public struct JointInfo {
    var lastPosition: SIMD3<Float>
    var lastTimeStamp: Double
    var velocity: Float
    var accleration: Float
    
    mutating func update(position: SIMD3<Float>) -> Bool {
        let timeStamp = Date().timeIntervalSince1970
        if timeStamp - lastTimeStamp > 0.0 {
            print("<RATE> Time: \(timeStamp), frame: \(timeStamp - lastTimeStamp)")
            let currentVelocity = simd_distance(position, lastPosition) / Float(timeStamp - lastTimeStamp)
            let currentAcceleration = (currentVelocity - velocity) / Float(timeStamp - lastTimeStamp)
            
            lastTimeStamp = timeStamp
            lastPosition = position
            print("<ACC> currentAcceleration: \(currentAcceleration)")
            print("<V> currentVelocity: \(currentVelocity)")
            if abs(currentVelocity) > 4.0 {
//                print("===== Want to trigger Effect ======")
                // get Audio Progress and Peak from global
                if isOnBeat() {
                    accleration = currentAcceleration
                    velocity = currentVelocity
                    // Trigger Effect
//                    print("Trigger Effect")
                    return true
                } else {
                    accleration = currentAcceleration
                    velocity = currentVelocity
                    return false
                }
            }
            accleration = currentAcceleration
            velocity = currentVelocity
        }
        return false
    }
    
    func isOnBeat() -> Bool {
        for p in peakSet {
            if abs(musicProgress - Double(p)) < 0.05 {
                return true
            }
        }
        return false
    }
}

public class BodySkeleton: Entity {
    private var effectEntities: [EffectEntity] = []
    private var joints: [String: Entity] = [:] // jointNames -> jointEntities
    private var jointInfos: [String: JointInfo] = [:]
    private var arView: ARView
    
    required init(for bodyAnchor: ARBodyAnchor, with arView: ARView) {
        self.arView = arView
        
        super.init()
        
//        audioViewModel.playOrPause()
        
        // MARK: Initialize Set
        peakSet.removeAll()
        for i in peaks {
            peakSet.insert(i.position)
        }
        
        
//        let soundUrl = Bundle.main.path(forResource: "dingsound", ofType: "wav")
//        soundEffectPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundUrl!))
//        soundEffectPlayer.prepareToPlay()
//        soundEffectPlayer.volume = 1.0
        
//        // MARK: Traverse Joints
//        // create entity for each joint in skeleton
//        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
//            // joint appear in sphere
//            var jointRadius: Float = 0.03
//            var jointColor: UIColor = .green
//
//            switch jointName {
//            case "neck_1_joint", "neck_2_joint", "neck_3_joint", "neck_4_joint", "head_joint", "left_shoulder_1_joint", "right_shoulder_1_joint":
//                jointRadius *= 0.5
//            case "jaw_joint", "chin_joint", "left_eye_joint", "left_eyeLowerLid_joint", "left_eyeUpperLid_joint", "left_eyeball_joint", "nose_joint", "right_eye_joint", "right_eyeLowerLid_joint", "right_eyeUpperLid_joint", "right_eyeball_joint":
//                jointRadius *= 0.2
//                jointColor = .yellow
//            case _ where jointName.hasPrefix("spine_"):
//                jointRadius *= 0.75
//            case "left_hand_joint", "right_hand_joint":
//                jointRadius *= 1
//                jointColor = .green
//            case _ where jointName.hasPrefix("left_hand") || jointName.hasPrefix("right_hand"):
//                jointRadius *= 0.25
//                jointColor = .yellow
//            case _ where jointName.hasPrefix("left_toes") || jointName.hasPrefix("right_toes"):
//                jointRadius *= 0.5
//                jointColor = .yellow
//            default:
//                jointRadius = 0.05
//                jointColor = .green
//            }
//
//            let jointEntity = makeJoint(radius: jointRadius, color: jointColor)
//            joints[jointName] = jointEntity
//            self.addChild(jointEntity)
//        }
        
        self.update(with: bodyAnchor)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func makeJoint(radius: Float, color: UIColor) -> Entity {
        let mesh = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: color, roughness: 0.8, isMetallic: false)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        return modelEntity
    }
    
    func isOnBeat() -> Bool {
        for p in peakSet {
            if abs(musicProgress - Double(p)) < 0.05 {
                return true
            }
        }
        return false
    }
    
    func update(with bodyAnchor: ARBodyAnchor) {
        let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        
        if isOnBeat() {
            print("<BEAT> is On Beat \(musicProgress)")
        }
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
            if let jointTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointName)) {
                let jointOffset = simd_make_float3(jointTransform.columns.3)
//                jointEntity.position = rootPosition + jointOffset
//                jointEntity.orientation = Transform(matrix: jointTransform).rotation
                let jointPosition = rootPosition + jointOffset
                
                // MARK: Update Joint Infos
                if jointName == "left_hand_joint" || jointName == "right_hand_joint" {
                    if jointInfos[jointName] == nil {
                        jointInfos[jointName] = JointInfo(lastPosition: jointPosition, lastTimeStamp: Date().timeIntervalSince1970, velocity: 0, accleration: 0)
                    } else {
//                        print("jointInfo \(jointInfos[jointName]!.accleration)")
                        if jointInfos[jointName]!.update(position: jointPosition) {
                            print("<EFFECT> trigger effect for: \(jointName)")
                            let modelName = allModels["gem"]![Int.random(in: 0...allModels["gem"]!.count - 1)]
                            let modelScale = modelScaleAndTranslation["gem"]![0]
                            triggerPhysicalEffect(at: jointPosition, scale: modelScale, name: modelName)
                        }
                    }
                }
                
                if jointName == "left_foot_joint" || jointName == "right_foot_joint" {
                    if jointInfos[jointName] == nil {
                        if !audioPlayer.isPlaying {
                            audioPlayer.volume = 0.2
                            audioPlayer.play()
                            globalTimer.fire()
                        }
                        jointInfos[jointName] = JointInfo(lastPosition: jointPosition, lastTimeStamp: Date().timeIntervalSince1970, velocity: 0, accleration: 0)
                    } else {
//                        print("jointInfo \(jointInfos[jointName]!.accleration)")
                        if jointInfos[jointName]!.update(position: jointPosition) {
                            print("<EFFECT> trigger effect for: \(jointName)")
                            triggerEffect(at: jointPosition, name: "Grass_A_0\(Int.random(in: 1...3)).usdz")
                        }
                    }
                }
                
            }
        }
        
//        let leftHandSpeed = jointInfos["left_hand_joint"]!.velocity
//        let rightHandSpeed = jointInfos["right_hand_joint"]!.velocity
//
//        // change audio rate and pitch
//        if leftHandSpeed > 0 && rightHandSpeed > 0 {
//            audioViewModel.playbackRate = (leftHandSpeed / rightHandSpeed) * 2
//            audioViewModel.playbackPitch = round((leftHandSpeed - rightHandSpeed) * 10)
//        }
    }
    
    // MARK: Tick for Effect
    public func tick() {
        for (index, item) in effectEntities.enumerated() {
            if !item.tick() {
                effectEntities.remove(at: index)
            }
        }
    }
    
    var lastTriggered = 0.0
//    var lock = false
//    var lockTimer: Timer!
//
//    @objc func updateLock() {
//        lock = false
//    }
    func triggerPhysicalEffect(at worldPosition: SIMD3<Float>, scale: SIMD3<Float>, name: String) {
        if musicProgress - lastTriggered < 0.5 {
            return
        }
        lastTriggered = musicProgress
        
        for _ in 1...4 {
            let linearVelocity = SIMD3<Float>(Float.random(in: -0.5..<0.5), Float.random(in: 1.0..<2.0), Float.random(in: -0.5..<0.5))
            let angularVelocity = SIMD3<Float>(0.2, 0, 0)
                
            let model = generateEntityWithPhysics(name, scale: scale, linearVelocity: linearVelocity, angularVelocity: angularVelocity)
            let anchorEntity = AnchorEntity(world: worldPosition)
            anchorEntity.addChild(model)
            arView.scene.addAnchor(anchorEntity)
        }
        
//        soundEffectPlayer.play()
        audioFactory.play()
    }
    
    // MARK: Trigger Effect
    func triggerEffect(at worldPosition: SIMD3<Float>, name: String) {
        if musicProgress - lastTriggered < 0.5 {
            return
        }
        lastTriggered = musicProgress
        
        let loadedModel = try!ModelEntity.load(named: name)
        let model = loadedModel.children[0].children[0]
        let modelEntity = ModelEntity()
        modelEntity.addChild(model)
        model.setScale([0.002, 0.002, 0.002], relativeTo: .none)
        let anchorEntity = AnchorEntity(world: worldPosition)
        anchorEntity.addChild(model)
        arView.scene.addAnchor(anchorEntity)
    }
    
    func generateEntityWithPhysics(_ filename: String, scale: SIMD3<Float>, linearVelocity: SIMD3<Float>, angularVelocity: SIMD3<Float>) -> ModelEntity {
        let loadedModel = try!ModelEntity.load(named: filename)
        let model = loadedModel.children[0].children[0].children[0]
        let modelEntity = ModelEntity()
        modelEntity.addChild(model)
        model.setScale(scale, relativeTo: .none)
        
        model.setOrientation(simd_quaternion(90.0, [1.0, 0, 0]).normalized, relativeTo: .none)
        modelEntity.generateCollisionShapes(recursive: true)
        
        if let collisionComponent = model.components[CollisionComponent.self] as? CollisionComponent {
            model.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 0.1, material: nil, mode: .dynamic)
            model.components[PhysicsMotionComponent.self] = PhysicsMotionComponent(linearVelocity: linearVelocity, angularVelocity: angularVelocity)
        }
        
        return modelEntity
    }
    
    func generateEntityWithKinematic(_ filename: String, linearVelocity: SIMD3<Float>, angularVelocity: SIMD3<Float>) -> ModelEntity {
        let loadedModel = try!ModelEntity.load(named: filename)
        let model = loadedModel.children[0].children[0]
        let modelEntity = ModelEntity()
        modelEntity.addChild(model)
        model.setScale([0.001, 0.001, 0.001], relativeTo: .none)
        modelEntity.generateCollisionShapes(recursive: true)
        
        if let collisionComponent = model.components[CollisionComponent.self] as? CollisionComponent {
            model.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(shapes: collisionComponent.shapes, mass: 0.1, material: nil, mode: .kinematic)
            model.components[PhysicsMotionComponent.self] = PhysicsMotionComponent(linearVelocity: linearVelocity, angularVelocity: angularVelocity)
        }
        
        return modelEntity
    }
    
    func generateEntityWithTransition(_ filename: String) -> ModelEntity {
        let loadedModel = try!ModelEntity.load(named: filename)
        let model = loadedModel.children[0].children[0]
        let modelEntity = ModelEntity()
        modelEntity.addChild(model)
        model.setScale([0.001, 0.001, 0.001], relativeTo: .none)
        
        let translate = Transform(scale: [2,2,2], rotation: simd_quatf(angle: -.pi / 6, axis: [1,0,0]), translation: [0, -0.1, 0])
        modelEntity.move(to: translate, relativeTo: modelEntity, duration: 1.0, timingFunction: .easeInOut)
        
        return modelEntity
    }
}
