//
//  ARViewExtension.swift
//  musefall
//
//  Created by Ziyi Lu on 2021/9/21.
//

import Foundation
import ARKit
import RealityKit

extension ARView: ARSessionDelegate {
    
    // Configure ARView for body tracking
    func setupForBodyTracking() {
        let config = ARBodyTrackingConfiguration()
        self.session.run(config)
        
        self.session.delegate = self
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
//                print("<DEBUG> Updated bodyAnchor")
//
//                let skeleton = bodyAnchor.skeleton
//
//                let rootJointTransform = skeleton.modelTransform(for: .root)!
//                let rootJointPosition = simd_make_float3(rootJointTransform.columns.3)
//                print("root: \(rootJointPosition)")
//
//                let leftHandTransform = skeleton.modelTransform(for: .leftHand)!
//                let leftHandOffset = simd_make_float3(leftHandTransform.columns.3)
//                let leftHandPosition = rootJointPosition + leftHandOffset
//                print("leftHand: \(leftHandPosition)")
                if let skeleton = bodySkeleton {
                    skeleton.update(with: bodyAnchor)
                } else {
                    // Seeing for the first time, create bodySkeleton
                    let skeleton = BodySkeleton(for: bodyAnchor, with: self)
                    bodySkeleton = skeleton
                    bodySkeletonAnchor.addChild(skeleton)
                }
            }
        }
    }
    
}
