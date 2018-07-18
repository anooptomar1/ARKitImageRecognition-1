//
//  ViewController.swift
//  Image Recognition
//
//  Created by Jayven Nhan on 3/20/18.
//  Edit By Marco Moreira.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
    
    let fadeDuration: TimeInterval = 0.3
    let rotateDuration: TimeInterval = 3
    let waitDuration: TimeInterval = 0.5
    
    lazy var fadeAndSpinAction: SCNAction = {
        return .sequence([
            .fadeIn(duration: fadeDuration),
            .rotateBy(x: 0, y: 0, z: CGFloat.pi * 360 / 180, duration: rotateDuration),
            .wait(duration: waitDuration),
            .fadeOut(duration: fadeDuration)
            ])
    }()
    
    lazy var spinAction: SCNAction = {
        return .sequence([
            .fadeIn(duration: fadeDuration)
            ])
    }()
    
    lazy var fadeAction: SCNAction = {
        return .sequence([
            .fadeOpacity(by: 0.8, duration: fadeDuration),
            .wait(duration: waitDuration),
            .fadeOut(duration: fadeDuration)
            ])
    }()
    
    
    
    lazy var videoNode: SCNNode = {
        
        let currentFrame = self.sceneView.session.currentFrame
        
        let videoNode = SKVideoNode(fileNamed: "video.mp4")
        videoNode.play()
        let skScene = SKScene(size: CGSize(width: 1280  , height: 720))
        skScene.addChild(videoNode)
        
        videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
        videoNode.size = skScene.size

        let tvPlane = SCNPlane(width: 1.0, height: 0.75)
        tvPlane.firstMaterial?.diffuse.contents = skScene
        tvPlane.firstMaterial?.isDoubleSided = true
        
        let tvPlaneNode = SCNNode(geometry: tvPlane)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        
        tvPlaneNode.eulerAngles = SCNVector3(Double.pi,0,0)
 
        let scaleFactor  = 0.2
        tvPlaneNode.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        tvPlaneNode.eulerAngles.x = GLKMathDegreesToRadians(90)
        return tvPlaneNode
    }()
    
    
    lazy var shipNode: SCNNode = {
        guard let scene = SCNScene(named: "ship.scn"),
            let node = scene.rootNode.childNode(withName: "ship", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.1
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = GLKMathDegreesToRadians(-90)
        return node
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        configureLighting()
    }
    
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @IBAction func resetButtonDidTouch(_ sender: UIBarButtonItem) {
        resetTrackingConfiguration()
    }
    
    func resetTrackingConfiguration() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
        label.text = "Move camera around to detect images"
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            guard let imageAnchor = anchor as? ARImageAnchor,
                let imageName = imageAnchor.referenceImage.name else { return }
            
            // TODO: Comment out code
            if (imageName == "video"){
                let planeNode = self.videoNode
                planeNode.opacity = 0.0
                planeNode.eulerAngles.x = .pi / 2
                planeNode.runAction(self.spinAction)
                node.addChildNode(planeNode)
            }
            
            if(imageName == "ship"){
                let overlayNode = self.getNode(withImageName: imageName)
                overlayNode.opacity = 0
                overlayNode.position.y = 0.2
                overlayNode.runAction(self.spinAction)
                
                node.addChildNode(overlayNode)
            }

            /*
            // TODO: Overlay 3D Object
            let overlayNode = self.getNode(withImageName: imageName)
            overlayNode.opacity = 0
            overlayNode.position.y = 0.2
            overlayNode.runAction(self.spinAction)
            
            node.addChildNode(overlayNode)
            
            */
            self.label.text = "\(imageName)"
        }
    }
    
    func getPlaneNode(withReferenceImage image: ARReferenceImage) -> SCNNode {
        let plane = SCNPlane(width: image.physicalSize.width,
                             height: image.physicalSize.height)
        let node = SCNNode(geometry: plane)
        return node
    }
    
    func getNode(withImageName name: String) -> SCNNode {
        var node = SCNNode()
        switch name {
        case "ship":
            node = shipNode
        case "video":
            node = videoNode
        default:
            break
        }
        return node
    }
    
}
