//
//  ViewController+NonRealityUI.swift
//  RealityUI+Examples
//
//  Created by Max Cobb on 5/24/20.
//  Copyright © 2020 Max Cobb. All rights reserved.
//

import RealityKit
//import RealityUI

class ContainerCube: Entity, HasPhysicsBody, HasModel {
    private static var boxPositions: [SIMD3<Float>] = [
        [-1, 0, 0],
        [1, 0, 0],
        [0, -1, 0],
        [0, 1, 0],
        [0, 0, -1],
        [0, 0, 1]
    ]
    required init(showingInterior: Bool) {
        super.init()
        self.collision = CollisionComponent(
            shapes: ContainerCube.boxPositions.map {
                ShapeResource.generateBox(size: [1, 1, 1]).offsetBy(translation: $0) },
            mode: .default, filter: CollisionFilter(
                group: .init(rawValue: 1 << 31),
                mask: .init(rawValue: 1 << 31)
            )
        )
        if showingInterior {
            let cubeModel = ModelEntity(
                mesh: .generateBox(size: 1), materials: [
                    SimpleMaterial(color: Material.Color.lightGray.withAlphaComponent(0.5), isMetallic: false)
                ])
            cubeModel.scale *= -1
            self.addChild(cubeModel)
        }
        self.physicsBody = PhysicsBodyComponent(shapes: ContainerCube.boxPositions.map {
            ShapeResource.generateBox(size: .one).offsetBy(translation: $0)
        }, mass: 1, mode: .static)
        //    self.model = ModelComponent(mesh: .generateBox(size: 0.2), materials: [])
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
