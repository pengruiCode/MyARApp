//
//  ViewController+RealityControls.swift
//  RealityUI+Examples
//
//  Created by Max Cobb on 5/24/20.
//  Copyright © 2020 Max Cobb. All rights reserved.
//

import RealityKit
import Foundation
import Combine
//import RealityUI


extension RealityKitVC {
    static var letRotate = false
    func addObjectToPlane() {
        let controlsAnchor = ControlsParent()
        controlsAnchor.position.z = -0.25
        var anchorFoundCallback: Cancellable?
        anchorFoundCallback = self.arView.scene.subscribe(
            to: SceneEvents.AnchoredStateChanged.self, on: controlsAnchor, { anchorEvent in
                if anchorEvent.isAnchored {
                    controlsAnchor.entityAnchored()
                    if RealityKitVC.letRotate {
                        let visBounds = controlsAnchor.visualBounds(relativeTo: controlsAnchor)
                        controlsAnchor.collision = CollisionComponent(shapes: [
                            ShapeResource.generateBox(size: visBounds.extents * 1.1).offsetBy(translation: visBounds.center)
                        ])
                        self.arView.installGestures(.rotation, for: controlsAnchor)
                    }
                    DispatchQueue.main.async { anchorFoundCallback?.cancel() }
                }
            }
        )
        self.arView.scene.addAnchor(controlsAnchor)
        let textAbove = RUIText(with: "RealityUI")
        textAbove.look(at: [0, 1.5, 0], from: [0, 1.5, -1], relativeTo: nil)
        controlsAnchor.addChild(textAbove)
    }
}
