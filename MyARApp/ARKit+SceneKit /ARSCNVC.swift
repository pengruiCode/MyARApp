//
//  ARSCNVC.swift
//  MyARApp
//
//  Created by 彭睿 on 2023/2/3.
//

import UIKit
import SceneKit
import ARKit

class ARSCNVC: UIViewController {

    // AR会话，负责管理相机追踪配置及3D相机坐标
    var arSession = ARSession()
    // AR视图：展示3D界面
    @IBOutlet weak var sceneView: ARSCNView!
    // 会话追踪配置：负责追踪相机的运动
//    lazy var arConfig: ARConfiguration = {
//        let c = ARWorldTrackingConfiguration()
//        c.planeDetection = .horizontal
//        c.isLightEstimationEnabled = true
//        return c
//    }()
    // 飞机3D模型(本小节加载多个模型)
    var planeNode = SCNNode()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        arSCNView.session = arSession
//        arSCNView.automaticallyUpdatesLighting = true
        
        addBox()
        addTapGestureToSceneView()
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
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // 1.使用场景加载scn文件（scn格式文件是一个基于3D建模的文件，使用3DMax软件可以创建，这里系统有一个默认的3D飞机）--------在右侧我添加了许多3D模型，只需要替换文件名即可
//        let scene = SCNScene.init(named: "Models.scnassets/chair/chair.scn")
//        // 2.获取飞机节点（一个场景会有多个节点，此处我们只写，飞机节点则默认是场景子节点的第一个）,所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
//        let shipNode = scene?.rootNode.childNodes.first
//        // 椅子比较大，可以可以调整Z轴的位置让它离摄像头远一点，，然后再往下一点（椅子太高我们坐不上去）就可以看得全局一点
//        // x/y/z/坐标相对于世界原点，也就是相机位置
//        shipNode?.position = SCNVector3Make(0, -1, -1)
//        // 3.将飞机节点添加到当前屏幕中
//        arSCNView.scene.rootNode.addChildNode(shipNode ?? SCNNode())
//    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(boxNode)
    }

    // 点击方块移除/点击空白新增
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation)
            guard let node = hitTestResults.first?.node else {
                let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
                if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                    let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                    addBox(x: translation.x, y: translation.y, z: translation.z)
                }
                return
            }
        node.removeFromParentNode()
    }
}


extension float4x4 {

    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
