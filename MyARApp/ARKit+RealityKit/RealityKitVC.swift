//
//  RealityKitVC.swift
//  MyARApp
//
//  Created by 彭睿 on 2023/2/9.
//

import UIKit
import RealityKit
import ARKit

class RealityKitVC: UIViewController, ARSessionDelegate {
    
    var arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
    
    func addARView() {
        arView.frame = self.view.bounds
        self.arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(arView)
        self.arView.renderOptions.insert(.disableGroundingShadows)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [])
        // Replaces camera feed, if 6dof VR look is wanted
        //    arView.environment.background = .color(.systemGray)
        
        // Register all the components used in RealityUI
        RealityUI.registerComponents()
        
        arView.session.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addARView()
        
        // Add all RealityUI gestures to the current ARView
        RealityUI.enableGestures(.all, on: self.arView)
        self.addObjectToPlane()
        
        
        // 首次进入提示
        let isShow = UserDefaults.standard.object(forKey: "KEY_REALITY_FIRST_SHOW") as? Int
        if isShow != 1 {
            UserDefaults.standard.setValue(1, forKey: "KEY_REALITY_FIRST_SHOW")
            let alert = UIAlertController(title: "效果提示", message: "当检测到平面，会添加3d模拟游戏，拥有新增方块，点击跳动等效果（如果没有看到，请转动屏幕范围查看）", preferredStyle: .alert)
            let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(sureAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

//struct ARViewContainer: UIViewRepresentable {
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = .horizontal
//        arView.session.run(config, options:[ ])
//        arView.session.delegate = arView
//        arView.createPlane()
//        return arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//
//    }
//}

var planeMesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
var planeMaterial = SimpleMaterial(color:.white,isMetallic: false)
var planeEntity  = ModelEntity(mesh:planeMesh,materials:[planeMaterial])
var planeAnchor = AnchorEntity()

extension ARView :ARSessionDelegate {
    func createPlane(){
        let planeAnchor = AnchorEntity(plane:.horizontal)
        do {
           planeMaterial.baseColor = try .texture(.load(named: "Surface_DIFFUSE.png"))
            planeMaterial.tintColor = UIColor.yellow.withAlphaComponent(0.9999)
           planeAnchor.addChild(planeEntity)
            self.scene.addAnchor(planeAnchor)
        } catch {
            print("找不到文件")
        }
    }

    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
       guard let pAnchor = anchors[0] as? ARPlaneAnchor else {
          return
        }
        DispatchQueue.main.async {
        planeEntity.model?.mesh = MeshResource.generatePlane(
          width: pAnchor.extent.x,
          depth: pAnchor.extent.z
        )
        planeEntity.setTransformMatrix(pAnchor.transform, relativeTo: nil)
        }
    }
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){
       guard let pAnchor = anchors[0] as? ARPlaneAnchor else {
          return
        }
        DispatchQueue.main.async {
        planeEntity.model?.mesh = MeshResource.generatePlane(
          width: pAnchor.extent.x,
          depth: pAnchor.extent.z
        )
        planeEntity.setTransformMatrix(pAnchor.transform, relativeTo: nil)
        }
    }
}
