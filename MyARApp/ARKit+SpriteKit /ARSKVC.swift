//
//  ARSKVC.swift
//  MyARApp
//
//  Created by 彭睿 on 2023/2/3.
//

import UIKit
import SpriteKit
import ARKit

class ARSKVC: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        let scene = Scene(size: sceneView.bounds.size)
        scene.scaleMode = .resizeFill
        sceneView.presentScene(scene)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        // 首次进入提示
        let isShow = UserDefaults.standard.object(forKey: "KEY_SPRITE_FIRST_SHOW") as? Int
        if isShow != 1 {
            UserDefaults.standard.setValue(1, forKey: "KEY_SPRITE_FIRST_SHOW")
            let alert = UIAlertController(title: "效果提示", message: "当检测到平面，会随机新增小玩偶，左下角显示当前小玩偶数量。当点击小玩偶会发出声音，并且消除掉当前小玩偶，模拟打地鼠游戏效果（如果没有看到小玩偶，请转动屏幕范围查看）", preferredStyle: .alert)
            let sureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(sureAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        let ghostId = randomInt(min: 1, max: 6)
        
        let node = SKSpriteNode(imageNamed: "ghost\(ghostId)")
        node.name = "ghost"
        
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
