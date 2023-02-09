//
//  ARSCNVCNew.swift
//  MyARApp
//
//  Created by 彭睿 on 2023/2/7.
//

import UIKit
import SceneKit
import ARKit

class ARSCNVCNew: UIViewController {
    
    // AR视图：展示3D界面
    @IBOutlet weak var sceneView: ARSCNView!
    // 飞机3D模型(本小节加载多个模型)
    var planeNode = SCNReferenceNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.showsStatistics = true
        DispatchQueue.main.async {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]
            self.sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        }
        
        createPlaneNode()
        addRecognizer()
        
        
        // 首次进入提示
        let isShow = UserDefaults.standard.object(forKey: "KEY_SECEN_FIRST_SHOW") as? Int
        if isShow != 1 {
            UserDefaults.standard.setValue(1, forKey: "KEY_SECEN_FIRST_SHOW")
            let alert = UIAlertController(title: "效果提示", message: "当检测到平面，会新增一个3d飞机模型，点击会旋转起飞，手动可拖拽xyz轴方向转动（如果没有看到，请转动屏幕范围查看）", preferredStyle: .alert)
            let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(sureAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let arConficg = ARWorldTrackingConfiguration()
        sceneView.session.run(arConficg)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // 加载星球模型
    func createEarch() {
        let scene = SCNScene(named: "ARResource.scnassets/SimpleScene.scn")!
        sceneView.scene = scene
    }
    
    // 读取飞机模型
    func createPlaneNode() {
        guard  let url = Bundle.main.url(forResource: "art.scnassets/ship", withExtension: "scn") else {
            fatalError("ship.scn not exit.")
        }
        
        let v:Float=0.3
        planeNode = SCNReferenceNode(url: url) ?? SCNReferenceNode()
        planeNode.load()
        planeNode.scale=SCNVector3Make(v, v, v)
        planeNode.name="ShipPlaneNode"
    }
    
    
}

// MARK: 操作相关
extension ARSCNVCNew {
    
    // 增加拖拽和缩放手势
    func addRecognizer() {
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(tapGest(withGestureRecognizer:)))
        let panGest = UIPanGestureRecognizer(target: self, action: #selector(panTap(withGestureRecognizer:)))
        let pinchGest = UIPinchGestureRecognizer(target: self, action: #selector(pinchTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGest)
        sceneView.addGestureRecognizer(panGest)
        sceneView.addGestureRecognizer(pinchGest)
    }
    
    // 处理拖拉手势 - 点击起飞到一定高度变为下降
    @objc func tapGest(withGestureRecognizer recognizer: UITapGestureRecognizer) {
        var y = planeNode.eulerAngles.y > 5 ? planeNode.eulerAngles.y - 0.3 : planeNode.eulerAngles.y + 0.3
        y = y < 0.3 ? planeNode.eulerAngles.y + 0.3 : planeNode.eulerAngles.y - 0.3
        
        let rotation = SCNAction.rotate(by: 3, around: SCNVector3Make(0, 1, 0), duration: 2)
        let moveUp = SCNAction.move(by: SCNVector3Make(0, y, 0), duration: 2)
        let group = SCNAction.group([rotation,moveUp])
        planeNode.runAction(group)
    }
    
    // 处理拖拉手势 - 移动 旋转
    @objc func panTap(withGestureRecognizer recognizer: UIPanGestureRecognizer) {
        let point = recognizer.velocity(in: sceneView)
        planeNode.eulerAngles = SCNVector3Make(planeNode.eulerAngles.x - Float(point.y/5000), planeNode.eulerAngles.y - Float(point.x/5000), planeNode.eulerAngles.z - Float(point.y/5000))
    }
    
    // 处理缩放手势
    @objc func pinchTap(withGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        if (recognizer.state == .changed) {
            let currentGesScale: CGFloat = recognizer.scale
            print("-------------------- currentGesScale = \(currentGesScale)")
            planeNode.scale = SCNVector3Make(Float(currentGesScale), Float(currentGesScale), planeNode.scale.z)
        }
    }
}


extension ARSCNVCNew: ARSCNViewDelegate {
    
    // 检测平面
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        if node.childNodes.contains(planeNode) == true {
            return
        }
        print("-----------------------> 检测到平面，添加模型")
        node.addChildNode(planeNode)
        
        // 添加环境光
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        node.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.white
        node.addChildNode(ambientLightNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
}


