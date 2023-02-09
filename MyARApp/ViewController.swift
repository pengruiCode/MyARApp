//
//  ViewController.swift
//  MyARApp
//
//  Created by 彭睿 on 2023/2/3.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "ARKit"
    }
    
    @IBAction func chick2D() {
        navigationController?.pushViewController(ARSKVC(), animated: true)
    }
    
    @IBAction func chick3D() {
        navigationController?.pushViewController(ARSCNVCNew(), animated: true)
    }
    
    @IBAction func chick3DAdd() {
        navigationController?.pushViewController(RealityKitVC(), animated: true)
    }
}

