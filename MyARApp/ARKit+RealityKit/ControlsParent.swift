//
//  ControlsParent.swift
//  MyARApp
//
//  Created by 彭睿 on 2023/2/9.
//

import RealityKit
import Foundation
import Combine
//import RealityUI

class ControlsParent: Entity, HasAnchoring, HasCollision, HasModel, HasTurnTouch {
    
    var tumbler: ContainerCube?
    var tumblingCubes: [ModelEntity] = []
    required init() {
        super.init()
        self.anchoring = AnchoringComponent(.plane(
            .horizontal, classification: .any, minimumBounds: [0.5, 0.5]
        ))
        self.maxDistance = 0.75
        self.addControls()
        /// Uncomment this to try out HasTurnTouch, but it's still in an experimental stage.
        if let rotateImg = try? TextureResource.load(named: "rotato") {
            self.collision = CollisionComponent(shapes: [.generateBox(size: [10, 0.1, 10])])
            var unlitTextured = UnlitMaterial(color: .white)
            unlitTextured.baseColor = MaterialColorParameter.texture(rotateImg)
            unlitTextured.tintColor = unlitTextured.tintColor.withAlphaComponent(0.75)
            self.model = ModelComponent(mesh: .generatePlane(width: 1.5, depth: 1.5), materials: [unlitTextured])
        }
    }
    
    func entityAnchored() {
        self.addTumbler()
    }
    
    /// Add all the RealityUI Controls
    func addControls() {
        let button = RUIButton(
            button: ButtonComponent(size: [2, 1, 0.4]),
            RUI: RUIComponent(respondsToLighting: true),
            updateCallback: { _ in self.popBoxes(power: 0.5)}
        )
        button.transform = Transform(
            scale: .init(repeating: 0.2),
            rotation: simd_quatf(angle: .pi / 2, axis: [1, 0, 0]), translation: .zero
        )
        self.addChild(button)
        let toggle = RUISwitch(changedCallback: { tog in
            if tog.isOn {
                self.tumbler?.spin(in: [0, 0, 1], duration: 3)
                self.popBoxes(power: 0.1)
            } else { self.tumbler?.ruiStopAnim() }
        })
        toggle.transform = Transform(
            scale: .init(repeating: 0.15), rotation: .init(angle: .pi, axis: [0, 1, 0]), translation: [0, 0.25, -0.25]
        )
        self.addChild(toggle)
        
        let slider = RUISlider(slider: SliderComponent(startingValue: 0.5, steps: 0)) { (slider, _) in
            self.tumblingCubes.forEach { $0.scale = .init(repeating: slider.value + 0.5)}
        }
        slider.transform = Transform(
            scale: .init(repeating: 0.1),
            rotation: .init(angle: .pi, axis: [0, 1, 0]),
            translation: [0, 1.15, -0.25]
        )
        self.addChild(slider)
        
        let minusPlusStepper = RUIStepper(upTrigger: { _ in
            if self.tumblingCubes.count <= 8 {
                self.spawnShape(with: SIMD3<Float>(repeating: slider.value + 0.5))
            }
        }, downTrigger: { _ in self.removeCube() })
        minusPlusStepper.transform = Transform(
            scale: .init(repeating: 0.15), rotation: .init(angle: .pi, axis: [0, 1, 0]), translation: [-0.5, 0.25, -0.25]
        )
        self.addChild(minusPlusStepper)
        let shapeStepper = RUIStepper(
            style: .arrowLeftRight,
            upTrigger: { stepper in self.shiftShape(1, on: stepper) },
            downTrigger: { stepper in self.shiftShape(-1, on: stepper) }
        )
        shapeStepper.transform = Transform(
            scale: .init(repeating: 0.15), rotation: .init(angle: .pi, axis: [0, 1, 0]), translation: [0.5, 0.25, -0.25]
        )
        self.addChild(shapeStepper)
        self.shiftShape(0, on: shapeStepper)
    }
    
    var currShape: Int = 0
    /// The object shapes that will be added
    var shiftShapes: [MeshResource] = [
        .generateBox(size: 0.2),
        // Slight problem with sphere and physics body, cause unknown to me
        .generateSphere(radius: 0.1),
        .generateBox(size: [0.2, 0.2, 0.01])
    ]
}


extension ControlsParent {
    func addTumbler() {
        let tumbler = ContainerCube(showingInterior: true)
        if let cubeColl = tumbler.collision {
            RealityUI.longGestureMask.remove(cubeColl.filter.group)
            RealityUI.tapGestureMask.remove(cubeColl.filter.group)
        }
        tumbler.position = [0, 0.75, -1.25]
        self.addChild(tumbler)
        self.tumbler = tumbler
    }
    func popBoxes(power: Float) {
        for cube in self.tumblingCubes {
            cube.applyImpulse([0, power * pow(cube.scale.x, 3), 0], at: .zero, relativeTo: nil)
        }
    }
    
    func shiftShape(_ shift: Int, on stepper: Entity) {
        self.currShape = (self.currShape + shift + self.shiftShapes.count)
        % self.shiftShapes.count
        for shape in self.tumblingCubes {
            shape.model?.mesh = self.shiftShapes[self.currShape]
            shape.collision = nil
            shape.physicsBody = nil
            shape.generateCollisionShapes(recursive: false)
            shape.collision?.filter = CollisionFilter(group: .all, mask: .all)
            shape.physicsBody = PhysicsBodyComponent(
                shapes: [.generateSphere(radius: 0.1)],
                mass: 1,
                material: .generate(friction: 20, restitution: 0.5),
                mode: .dynamic
            )
        }
        var shapeVisualised = stepper.findEntity(named: "shapeVisualised")
        if shapeVisualised == nil {
            let visModel = ModelEntity()
            visModel.name = "shapeVisualised"
            visModel.scale = .init(repeating: 3)
            visModel.position.y = 1
            stepper.addChild(visModel)
            shapeVisualised = visModel
        }
        shapeVisualised?.stopAllAnimations()
        (shapeVisualised as? ModelEntity)?.model = ModelComponent(
            mesh: self.shiftShapes[self.currShape],
            materials: [
                UnlitMaterial(color: Material.Color.blue.withAlphaComponent(0.9))
            ]
        )
        shapeVisualised?.spin(in: [0, 1, 0], duration: 5)
    }
    func removeCube() {
        if tumblingCubes.isEmpty {
            return
        }
        let lastCube = tumblingCubes.removeLast()
        lastCube.removeFromParent()
    }
    
    func spawnShape(with scale: SIMD3<Float>) {
        let newCube = ModelEntity(
            mesh: self.shiftShapes[self.currShape],
            materials: [SimpleMaterial(color: .blue, isMetallic: false)]
        )
        newCube.generateCollisionShapes(recursive: false)
        newCube.collision?.filter = CollisionFilter(group: .all, mask: .all)
        newCube.physicsBody = PhysicsBodyComponent(
            shapes: [.generateConvex(from: self.shiftShapes[self.currShape])],
            mass: 1,
            material: .generate(friction: 0.8, restitution: 0.3),
            mode: .dynamic
        )
        newCube.orientation = .init(angle: .pi / 1.5, axis: [1, 0, 0])
        newCube.scale = scale
        tumbler?.addChild(newCube)
        tumblingCubes.append(newCube)
    }
}
